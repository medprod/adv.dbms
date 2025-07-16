select datname, usename, application_name,
query_start, state_change, wait_event, wait_event_type, state, query
from pg_stat_activity
WHERE application_name = 'pgAdmin 4 - CONN:3009933'
