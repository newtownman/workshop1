# 청취 평정 실험 스켈레톤

음성을 들려주고 문항에 답하게 하는 웹 실험 틀입니다. `index.html` 파일 하나로 돌아가요.

## 파일 구성

- `index.html` — 평정 실험. 위쪽 **CONFIG** 블록만 고치면 됩니다.
- `recording.html` — 녹음 과제. 구조는 같습니다.
- `GUIDE.md` — 내 실험으로 바꾸는 법 + Claude에게 시키는 프롬프트 틀
- `schema.sql` — Supabase에 붙여넣을 테이블·권한 설정
- `audio/` `video/` `image/` — 연습용 견본 자극

## 지금 상태로 이미 돌아가는 것

자극은 **음성 · 영상 · 이미지 · 글자 · 자극 없음(설문)** 다섯 가지,
응답은 **척도 · 슬라이더 · 하나 고르기(2AFC/n-AFC) · 여러 개 고르기 · 자유 응답 · 미국 지도** 여섯 가지가
전부 켜진 상태입니다. CONFIG에서 안 쓰는 걸 지우고 쓰는 걸 남기세요.

## 1단계: 데모 모드로 돌려보기 (계정 필요 없음)

인터넷이 없어도 `index.html`을 더블클릭하면 브라우저에서 돌아갑니다.

`SUPABASE_URL`, `SUPABASE_KEY`를 비워두면 데모 모드입니다. 응답은 브라우저 메모리에만 남고, 마지막 화면에서 CSV로 받을 수 있어요.
CONFIG에서 문항·문구·자극을 바꾸고 새로고침하면서 확인하세요. 주소 끝에 `?dev`를 붙이면 화면 이동 패널이 나옵니다.

## 2단계: GitHub Pages로 배포

1. 이 저장소 위쪽의 초록색 **Use this template** → Create a new repository → 이름 정하고 **Public** → Create
2. 새로 생긴 내 저장소에서 Settings → Pages → Branch: `main` / `(root)` → Save
3. 자극 파일을 해당 폴더에 넣고, CONFIG의 `STIMULI` 목록을 파일명과 똑같이 맞추기
4. 1~2분 뒤 `https://<아이디>.github.io/<저장소>/` 로 접속 (녹음 과제는 끝에 `recording.html`)

저장소는 **public**이어야 Pages가 무료로 켜집니다. 자극 파일을 브라우저로 올릴 때는 개당 25MB까지입니다.
고쳤는데 화면이 안 바뀌면 1분쯤 기다린 뒤 **Ctrl+Shift+R** (맥: Cmd+Shift+R).

## 3단계: Supabase 연결 (실제 데이터 수집)

1. Supabase에서 새 프로젝트 만들기
2. SQL Editor에 `schema.sql` 내용을 붙여넣고 Run
3. Project Settings → API에서 **Project URL**과 **공개용 키(anon / publishable)**를 복사해 CONFIG에 넣기
   (service_role / secret 키는 절대 넣지 마세요. 이 파일은 누구나 볼 수 있습니다.)
4. 한 번 직접 참여해 보고 Table Editor에 행이 쌓이는지 확인

## 데이터 받기

녹음 파일은 Storage → `recordings` 버킷에 참가자별 폴더로 쌓이고, 목록은 `recordings` 테이블에 있습니다.


Table Editor → 테이블 선택 → Export → CSV.
`responses`는 **문항 하나가 한 행**(long format)입니다. 열: `participant_id, nickname, stimulus, trial_index, question_id, value, responded_at`.
넓은 표가 필요하면 R `tidyr::pivot_wider()`나 엑셀 피벗으로 펼치세요.
여러 개 고르기 문항은 `친근함|밝음`처럼 `|`로 이어져 저장됩니다 (R: `strsplit(value, "|", fixed = TRUE)`).
