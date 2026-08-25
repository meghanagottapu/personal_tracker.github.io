import { requireClient } from './supabase.js';
export async function listJobs() { const { data, error } = await requireClient().from('jobs').select('*').order('active', { ascending: false }).order('name'); if (error) throw error; return data || []; }
export async function saveJob(job, id = null) { const payload = { name: job.name.trim(), hourly_rate: Number(job.hourly_rate), active: job.active !== false }; const query = id ? requireClient().from('jobs').update(payload).eq('id', id) : requireClient().from('jobs').insert(payload); const { error } = await query; if (error) throw error; }
export async function deactivateJob(id) { const { error } = await requireClient().from('jobs').update({ active: false }).eq('id', id); if (error) throw error; }
