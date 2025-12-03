-- Enable RLS on storage.objects
alter table storage.objects enable row level security;

-- Allow public read access to the 'events-media' bucket
create policy "Public Access"
on storage.objects for select
using ( bucket_id = 'events-media' );

-- Allow authenticated users to upload files to the 'events-media' bucket
create policy "Authenticated Upload"
on storage.objects for insert
with check (
  bucket_id = 'events-media'
  and auth.role() = 'authenticated'
);

-- Allow users to update their own files (optional, but good for edits)
create policy "Owner Update"
on storage.objects for update
using (
  bucket_id = 'events-media'
  and auth.uid() = owner
);

-- Allow users to delete their own files
create policy "Owner Delete"
on storage.objects for delete
using (
  bucket_id = 'events-media'
  and auth.uid() = owner
);
