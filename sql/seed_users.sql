-- =========================================================
-- SEED DE USUARIOS DE PRUEBA PARA SUPABASE & IINICIA
-- Ejecuta este script en el SQL Editor de tu proyecto en Supabase
-- =========================================================

-- 1. Insertar usuarios en auth.users (Supabase Auth) con contraseña 'password123'
-- Nota: Supabase genera automáticamente un UUID para cada usuario auth.
-- Puedes ejecutar esto desde el SQL Editor de Supabase:

INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, aud, role)
VALUES
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'alex.rodriguez@inicia.edu.mx', crypt('password123', gen_salt('bf')), NOW(), '{"provider":"email","providers":["email"]}', '{"first_name":"Alex","last_name":"Rodríguez"}', 'authenticated', 'authenticated'),
  ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'elena.gomez@inicia.edu.mx', crypt('password123', gen_salt('bf')), NOW(), '{"provider":"email","providers":["email"]}', '{"first_name":"Elena","last_name":"Gómez"}', 'authenticated', 'authenticated'),
  ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c33', 'admin@inicia.edu.mx', crypt('password123', gen_salt('bf')), NOW(), '{"provider":"email","providers":["email"]}', '{"first_name":"Admin","last_name":"General"}', 'authenticated', 'authenticated')
ON CONFLICT (id) DO NOTHING;

-- 2. Insertar perfiles correspondientes en la tabla pública 'users'
INSERT INTO public.users (id, auth_user_id, email, first_name, last_name, phone, status, moodle_user_id)
VALUES
  (uuid_generate_v4(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'alex.rodriguez@inicia.edu.mx', 'Alex', 'Rodríguez', '+52 555 123 4567', 'active', 20245892),
  (uuid_generate_v4(), 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'elena.gomez@inicia.edu.mx', 'Elena', 'Gómez', '+52 555 987 6543', 'active', 1001),
  (uuid_generate_v4(), 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c33', 'admin@inicia.edu.mx', 'Admin', 'General', '+52 555 000 0000', 'active', 1)
ON CONFLICT (email) DO NOTHING;

-- 3. Asignar roles a los usuarios en 'user_roles'
-- Estudiante (alex.rodriguez@inicia.edu.mx -> rol 'student')
INSERT INTO public.user_roles (user_id, role_id)
SELECT u.id, r.id FROM public.users u, public.roles r
WHERE u.email = 'alex.rodriguez@inicia.edu.mx' AND r.name = 'student'
ON CONFLICT DO NOTHING;

-- Profesor (elena.gomez@inicia.edu.mx -> rol 'teacher')
INSERT INTO public.user_roles (user_id, role_id)
SELECT u.id, r.id FROM public.users u, public.roles r
WHERE u.email = 'elena.gomez@inicia.edu.mx' AND r.name = 'teacher'
ON CONFLICT DO NOTHING;

-- Administrador (admin@inicia.edu.mx -> rol 'superadmin')
INSERT INTO public.user_roles (user_id, role_id)
SELECT u.id, r.id FROM public.users u, public.roles r
WHERE u.email = 'admin@inicia.edu.mx' AND r.name = 'superadmin'
ON CONFLICT DO NOTHING;
