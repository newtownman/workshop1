-- ============================================================
-- Supabase 대시보드 → SQL Editor 에 통째로 붙여넣고 Run (한 번만)
-- 평정 실험(index.html)과 녹음 과제(recording.html) 둘 다 이걸로 준비됨
-- ============================================================

-- 1) 테이블 ---------------------------------------------------

-- 참가자 1명 = 1행. 자극 순서와 진행 위치를 저장해서 '이어하기'에 씀
create table participants (
  id                uuid primary key default gen_random_uuid(),
  nickname          text unique not null,
  sample_order      jsonb not null,
  last_sample_index int not null default 0,
  completed         boolean not null default false,   -- 평정 과제 완료
  finished_at       timestamptz,                      -- 정보 입력까지 전부 완료
  created_at        timestamptz not null default now()
);

-- 응답: 문항 1개 = 1행 (long format). 문항을 바꿔도 이 테이블은 그대로 씀
create table responses (
  id             bigint generated always as identity primary key,
  participant_id uuid references participants(id),
  nickname       text,
  stimulus       text,
  trial_index    int,
  question_id    text,
  value          text,
  responded_at   timestamptz,
  created_at     timestamptz not null default now()
);

-- 참가자 정보: 항목 1개 = 1행
create table participant_info (
  id             bigint generated always as identity primary key,
  participant_id uuid references participants(id),
  nickname       text,
  field_id       text,
  value          text,
  submitted_at   timestamptz,
  created_at     timestamptz not null default now()
);

-- 2) 접근 권한 ------------------------------------------------

grant select, insert, update on public.participants     to anon;
grant insert                 on public.responses        to anon;
grant insert                 on public.participant_info to anon;
-- 공개 키로 들어온 참가자는 '쓰기'만 가능. 응답·개인정보를 읽는 건 대시보드(연구자)만.
-- participants만 이어하기 때문에 읽기/수정이 필요함 (개인정보는 없음).

alter table participants     enable row level security;
alter table responses        enable row level security;
alter table participant_info enable row level security;

create policy "participants: read"   on participants for select to anon using (true);
create policy "participants: insert" on participants for insert to anon with check (true);
create policy "participants: update" on participants for update to anon using (true) with check (true);

create policy "responses: insert"        on responses        for insert to anon with check (true);
create policy "participant_info: insert" on participant_info for insert to anon with check (true);

-- 3) 녹음 과제 (recording.html) ---------------------------------

-- 녹음 1개 = 1행. 실제 소리 파일은 Storage의 recordings 버킷에 저장되고, 여기엔 위치만 기록
create table recordings (
  id            bigint generated always as identity primary key,
  nickname      text not null,
  prompt_id     text not null,
  file_path     text not null,
  duration_sec  real,
  mime_type     text,
  recorded_at   timestamptz,
  created_at    timestamptz not null default now()
);
grant select, insert on public.recordings to anon;
alter table recordings enable row level security;
create policy "recordings: insert" on recordings for insert to anon with check (true);
create policy "recordings: read"   on recordings for select to anon using (true);   -- 이어하기용 (파일 자체는 비공개)

-- 녹음 파일 보관함(버킷). public = false → 참가자는 올리기만 가능, 듣기·내려받기는 대시보드(연구자)만
insert into storage.buckets (id, name, public) values ('recordings', 'recordings', false);
create policy "recordings bucket: upload" on storage.objects for insert to anon with check (bucket_id = 'recordings');
