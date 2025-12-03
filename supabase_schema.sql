-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- PROFILES TABLE
create table profiles (
  id uuid references auth.users on delete cascade not null primary key,
  email text not null,
  role text not null check (role in ('admin', 'user')) default 'user',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table profiles enable row level security;

create policy "Public profiles are viewable by everyone." on profiles
  for select using (true);

create policy "Users can update own profile." on profiles
  for update using (auth.uid() = id);

-- EVENTS TABLE
create table events (
  id uuid default uuid_generate_v4() primary key,
  title text not null,
  description text,
  location text not null,
  start_time timestamp with time zone not null,
  end_time timestamp with time zone not null,
  created_by uuid references profiles(id) not null,
  images text[] default '{}',
  video_url text,
  attendees_count int default 0,
  status text check (status in ('upcoming', 'ongoing', 'completed')) default 'upcoming',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table events enable row level security;

create policy "Events are viewable by everyone." on events
  for select using (true);

create policy "Admins can insert events." on events
  for insert with check (
    exists (select 1 from profiles where id = auth.uid() and role = 'admin')
  );

create policy "Admins can update events." on events
  for update using (
    exists (select 1 from profiles where id = auth.uid() and role = 'admin')
  );

create policy "Admins can delete events." on events
  for delete using (
    exists (select 1 from profiles where id = auth.uid() and role = 'admin')
  );

-- ATTENDEES TABLE
create table attendees (
  event_id uuid references events(id) on delete cascade not null,
  user_id uuid references profiles(id) on delete cascade not null,
  status text check (status in ('interested')) default 'interested',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (event_id, user_id)
);

alter table attendees enable row level security;

create policy "Attendees are viewable by everyone." on attendees
  for select using (true);

create policy "Users can insert their own attendance." on attendees
  for insert with check (auth.uid() = user_id);

create policy "Users can delete their own attendance." on attendees
  for delete using (auth.uid() = user_id);

-- TRIGGER TO HANDLE NEW USER SIGNUP
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, role)
  values (
    new.id,
    new.email,
    case 
      when new.email like '%@admin.com' then 'admin'
      else 'user'
    end
  );
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- RPC TO DECREMENT ATTENDEES
create or replace function decrement_attendees(row_id uuid)
returns void as $$
begin
  update events
  set attendees_count = attendees_count - 1
  where id = row_id;
end;
$$ language plpgsql;

-- TRIGGER TO INCREMENT ATTENDEES
create or replace function increment_attendees_count()
returns trigger as $$
begin
  update events
  set attendees_count = attendees_count + 1
  where id = new.event_id;
  return new;
end;
$$ language plpgsql;

create trigger on_attendee_added
  after insert on attendees
  for each row execute procedure increment_attendees_count();

-- STORAGE BUCKETS
-- You need to create 'events-media' bucket in Supabase dashboard manually or via API if possible.
-- Policy for storage:
-- Public Read
-- Authenticated Upload (or Admin only depending on reqs, but Admin creates events so Admin only upload makes sense)
