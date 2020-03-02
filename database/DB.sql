-- NOTA: Modificar datos de la línea 162-164 (por ahora están mis datos)

-- Drop de las tablas
drop table if exists registro_receta_sueros;
drop table if exists registro_receta;
drop table if exists receta;
drop table if exists hora;
drop table if exists indmedicas_sueros;
drop table if exists indMedicas;
drop table if exists indicaciones;
drop table if exists ficha;
drop table if exists medicamento_suero;
drop table if exists medicamento;
drop table if exists suero;
drop table if exists via;
drop table if exists paciente;
drop table if exists enfermera;
drop table if exists medico;
drop table if exists admin;
drop table if exists usuario;
drop table if exists persona;

-- Timezone
set timezone='America/Santiago';

-- Crear tablas
create table user_type(
  user_t varchar(20) primary key
)

create table usuario(
	rut varchar(15) primary key,
	pswd varchar(128) not null,
  nombres text not null,
  apellidos text not null,
	bloqueadoS_N boolean not null default false,
  especialidad text,
  user_type_id varchar(20),
	foreign key(user_type_id) references user_type(user_t)
);


create table paciente(
	rut varchar(15) primary key,
  nombres text not null,
  apellidos text not null,
	fechaNac date not null,
	alergia text,
);

create table via(
	nombre varchar(50) primary key
);

create table suero(
	codSuero serial primary key,
	nombre varchar(50) not null
);

create table medicamento(
	codMed serial primary key,
	nombre varchar(100) not null,
	dosisRecomendada numeric,
	dosisMax numeric,
	solitoS_N boolean not null default false,
	via varchar(50),
	frecuenciarecomendada integer default 8 not null,
	comprimidos numeric default 1 not null,
	unidad text default 'mg' not null,
	textoayuda text default '' not null,
	dosisunidad text default 'mg',
	dosismaxunidad text default 'mg' not null,
	foreign key (via) references via(nombre) on delete set null
);

create table medicamento_suero(
	codMed int,
	codSuero int,
	cantDefecto int not null default 1,
	primary key (codMed, codSuero),
	foreign key (codMed) references medicamento(codMed) on delete cascade,
	foreign key (codSuero) references suero(codSuero) on delete cascade
);

create table ficha(
	codFicha serial primary key,
	diagnostico text default '',
	fechaIngreso timestamp,
	fechaFicha timestamp not null default now(),
	pesoIngreso decimal,
	pesoActual decimal,
	estadoPaciente varchar(200),
	rutMedico varchar(15),
	rutEnfermera varchar(15),
	rutPaciente varchar(15),
	numficha integer default -1 not null,
	foreign key(rutMedico) references usuario(rut),
	foreign key(rutEnfermera) references usuario(rut),
	foreign key(rutPaciente) references paciente(rut)
);

create table indicaciones(
	codFicha int not null,
	numero serial not null,
	comentario text not null default '',
	categoria varchar(20) not null default 'Médica',
	primary key (codFicha, numero),
	foreign key (codFicha) references ficha(codFicha) on delete cascade
);

create table indMedicas(
	codFicha int not null,
	numero int not null,
	frecuenciaHoras int not null,
	dosis decimal not null,
	dias int not null,
	codMed int not null,
	dosisunidad text default 'mg' not null,
	primary key (codFicha, numero),
	foreign key (codFicha, numero) references indicaciones(codFicha, numero) on delete cascade,
	foreign key (codMed) references medicamento(codMed) on delete set null
);

create table indMedicas_sueros(
	codFicha int not null,
	numero int not null,
	codsuero int not null,
	cc int not null,
	primary key (codFicha, numero, codsuero),
	foreign key (codFicha, numero) references indmedicas(codFicha, numero) on delete cascade,
	foreign key (codsuero) references suero(codsuero) on delete set null
);

create table hora(
	codFicha int not null,
	numero int not null,
	hora time not null,
	primary key (codFicha, numero, hora),
	foreign key (codFicha, numero) references indMedicas(codFicha, numero) on delete cascade
);

create table receta(
	codReceta serial primary key,
	fechaReceta timestamp without time zone not null default now(),
	codFicha int,
	rutpaciente varchar(15),
	rutmedico varchar(15),
	pesopaciente numeric default 0 not null,
	foreign key (codFicha) references ficha(codFicha) on delete set null,
	foreign key (rutpaciente) references paciente(rut) on delete cascade,
	foreign key (rutmedico) references usuario(rut) on delete cascade
);

create table registro_receta(
	codReceta int not null,
	numero serial not null,	
	frecuenciaHoras int not null,
	dosis decimal not null,
	dias int not null,
	codMed int not null,
	dosisunidad text default 'mg' not null,
	totalmed integer default 1 not null,
	primary key (codReceta, numero),
	foreign key (codReceta) references receta(codreceta) on delete cascade,
	foreign key (codMed) references medicamento(codMed) on delete set null
);

create table registro_receta_sueros(
	codReceta int not null,
	numero serial not null,	
	codsuero int not null,
	cc int,
	totalsuero integer default 1 not null,
	primary key (codReceta, numero, codsuero),
	foreign key (codReceta, numero) references registro_receta(codReceta, numero) on delete cascade,
	foreign key (codsuero) references suero(codsuero) on delete set null
);

INSERT INTO user_type(user_t) VALUES ('ADMIN');
INSERT INTO user_type(user_t) VALUES ('ADMIN-ENF');
INSERT INTO user_type(user_t) VALUES ('ADMIN-MED');
INSERT INTO user_type(user_t) VALUES ('ENF');
INSERT INTO user_type(user_t) VALUES ('MED');

create table system_page(
	id serial,
	text text,
	link text, 
	icon text,
	primary key(id)
);

create table user_permission(
	id serial,
	system_page_id bigint,
	user_type_id text,
	primary key(id),
	foreign key (system_page_id) references system_page(id),
	foreign key (user_type_id) references user_type(user_t)
)


--INSERTS.
INSERT INTO usuario(rut, pswd, nombres, apellidos, especialidad, user_type_id) VALUES ('11.111.111-1', '3a781cc80ceb5f3906901cafd6ddcb9e16ee08fe96ab1638d7e546b9219180377d3bcb8997da2a4b57ab36b36535ef6fe399a9f16920d46acf46f8e0d6490aa8',
                                                          'Usuario', 'Prueba', 'Nada', 'ADMIN-MED');
-- INSERT INTO usuario(rut, pswd) VALUES ('17.679.133-0', '3a781cc80ceb5f3906901cafd6ddcb9e16ee08fe96ab1638d7e546b9219180377d3bcb8997da2a4b57ab36b36535ef6fe399a9f16920d46acf46f8e0d6490aa8');
-- INSERT INTO admin(rut) VALUES('17.679.133-0');
-- Pass: hospped2018

-- vias
INSERT INTO via VALUES ('Endotraqueal');
INSERT INTO via VALUES ('EV directa');
INSERT INTO via VALUES ('EV inf. intermitente');
INSERT INTO via VALUES ('EV inf. continua');
INSERT INTO via VALUES ('Epidural');
INSERT INTO via VALUES ('Inhalatoria');
INSERT INTO via VALUES ('Intranasal');
INSERT INTO via VALUES ('Intraosea');
INSERT INTO via VALUES ('Intramuscular');
INSERT INTO via VALUES ('Intraarticular');
INSERT INTO via VALUES ('Intratecal');
INSERT INTO via VALUES ('Intravitreal');
INSERT INTO via VALUES ('Oftálmica');
INSERT INTO via VALUES ('Oral');
INSERT INTO via VALUES ('Ótica');
INSERT INTO via VALUES ('Parenteral');
INSERT INTO via VALUES ('Rectal');
INSERT INTO via VALUES ('Subcutánea');
INSERT INTO via VALUES ('Vaginal');
INSERT INTO via VALUES ('Transdérmico');
INSERT INTO via VALUES ('Via Tópica');
-- suero
INSERT INTO suero(nombre) VALUES ('suero fisiológico');
INSERT INTO suero(nombre) VALUES ('suero glucosado al 5%');
INSERT INTO suero(nombre) VALUES ('suero glucosado al 10%');
INSERT INTO suero(nombre) VALUES ('suero glucosado');
INSERT INTO suero(nombre) VALUES ('agua para inyectables');
INSERT INTO suero(nombre) VALUES ('ringer lactato');
INSERT INTO suero(nombre) VALUES ('suero glucosalino');
INSERT INTO suero(nombre) VALUES ('solución fisiológica de 0.9%');

-- Medicamentos:
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Abciximab Fa De 5ml: 10mg', 0.25, 0.036, false, 'EV directa', 10, 24, 'mg', 'Dosis: 0.25 mg/kg/dosis inicio, seguida de 0.125 mcg/kg/min (máximo 10 mcg/min) por 12 horas.
Dilución: Administración en infusión continua se recomienda a 36 mcg/ml (0.036 mg/ml)', 'mg/kg', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Abciximab Fa De 5ml: 10mg', 0.25, 0.036, false, 'EV inf. continua', 10, 24, 'mg', 'Dosis: 0.25 mg/kg/dosis inicio, seguida de 0.125 mcg/kg/min (máximo 10 mcg/min) por 12 horas.
Dilución: Administración en infusión continua se recomienda a 36 mcg/ml (0.036 mg/ml)', 'mg/kg', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Aciclovir Sal sódica 250mg: ampolla 10ml', 45, 100, false, 'Oral',10 , 8,'mg', 'encefalitis 0 a 1 mes: 60mg/kg/día; 1 mes a 12 años: 45 mg/kg/día;12 años en adelante: 30 mg/kg/día c/8 hrs.', 'mg/kg', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Aciclovir Sal sódica 500mg: ampolla 20ml', 45, 200, false, 'Oral', 10, 8,'mg', 'encefalitis 0 a 1 mes: 60mg/kg/día; 1 mes a 12 años: 45 mg/kg/día;12 años en adelante: 30 mg/kg/día c/8 hrs.', 'mg/kg', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Aciclovir Sal sódica 250mg: ampolla 10ml', 45, 100, false, 'EV directa', 10, 8,'mg', 'encefalitis 0 a 1 mes: 60mg/kg/día; 1 mes a 12 años: 45 mg/kg/día;12 años en adelante: 30 mg/kg/día c/8 hrs.', 'mg/kg', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Aciclovir Sal sódica 500mg: ampolla 20ml', 45, 200, false, 'EV directa', 10, 8,'mg', 'encefalitis 0 a 1 mes: 60mg/kg/día; 1 mes a 12 años: 45 mg/kg/día;12 años en adelante: 30 mg/kg/día c/8 hrs.', 'mg/kg', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Acido Tranexámico, FA 10ml:1000mg', 10, 1000, false, 'EV directa',1 , 6,'mg', 'Dosis: Directa: 10-15mg/kg/dosis 3 a 4 veces al día.', 'mg/kg', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Acido Tranexámico, FA 10ml:1000mg', 10, 1000, false, 'EV directa', 1, 8,'mg', 'Dosis: Directa: 10-15mg/kg/dosis 3 a 4 veces al día.', 'mg/kg', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Acido Tranexámico, FA 10ml:1000mg', 45, 1000, false, 'EV inf. continua', 1, 24,'mg', 'Dosis: Infusión continua: 45 mg/kg/día(31,2 mcg/kg/min).', 'mg/kg', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Acido Tranexámico, FA 10ml:1000mg', 45, 1000, false, 'EV inf. intermitente', 1, 24,'mg', 'Dosis: Infusión continua: 45 mg/kg/día(31,2 mcg/kg/min).', 'mg/kg', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Acido Tranexámico, FA 10ml:1000mg', 45, 1000, false, 'Intramuscular',1 , 24,'mg', 'Dosis: Infusión continua: 45 mg/kg/día(31,2 mcg/kg/min).', 'mg/kg', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Acido Valproico, Vial 5ml: 500mg', 10, 250, false, 'Oral',1 , 8,'mg', 'Dosis: Inicial endovenosa oral: 10 - 15 mg/kg/día cada 8 a 12 hrs. Incrementar por 5 a 10 mg/kg/ c/ 2 semanas hasta los 30-60 mg/kg/día.
 Status epiléctico: Bolo inicial 20 a 30 mg/kg, si no hay control administrar nueva dosis de 10 mg/kg, tras media hora pasar a infusión continua de 5mg/kg/hora', 'mg/kg', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Acido Valproico, Vial 5ml: 500mg', 10, 1000, false, 'EV directa',1 , 8,'mg', 'Dosis: Inicial endovenosa oral: 10 - 15 mg/kg/día cada 8 a 12 hrs. Incrementar por 5 a 10 mg/kg/ c/ 2 semanas hasta los 30-60 mg/kg/día.', 'mg/kg', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Acido Valproico, Vial 5ml: 500mg', 10, 1000, false, 'EV inf. intermitente', 1, 8,'mg', 'Dosis: Inicial endovenosa oral: 10 - 15 mg/kg/día cada 8 a 12 hrs. Incrementar por 5 a 10 mg/kg/ c/ 2 semanas hasta los 30-60 mg/kg/día.', 'mg/kg', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Acido Valproico, Vial 5ml: 500mg', 10, 25, false, 'EV inf. continua', 1, 8,'mg', 'Dosis: Inicial endovenosa oral: 10 - 15 mg/kg/día cada 8 a 12 hrs. Incrementar por 5 a 10 mg/kg/ c/ 2 semanas hasta los 30-60 mg/kg/día.',
'mg/kg', 'mg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Adenosina Vial 2ml:6mg', 0.1, 6, false, 'EV directa', 1, 24,'mg', 'Dosis: 1a dosis:  0.1mg/kg --  2da dosis: 0.2mg/kg',
'mg/kg', 'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Adrenalina	FA 1ml: 1mg (Vitrartato)', 0.01, 1, false, 'EV directa', 1, 24,'mg', 'Paro cardiorespiratorio, bradicardia: 0.01 mg/kg (0.1 ml/kg) cada 3 - 5 min. 0.1 mg/kg (0.1ml/kg) para tubo endotraqueal. Shock hipotensivo 0.1 - 1 mg/kg Infusión continua. 0.01 mg/kg endovenosa intramuscular
','mg/kg', 'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Adrenalina	FA 1ml: 1mg (Vitrartato)', 0.01, 1, false, 'EV inf. intermitente', 1, 24,'mg', 'Paro cardiorespiratorio, bradicardia: 0.01 mg/kg (0.1 ml/kg) cada 3 - 5 min. 0.1 mg/kg (0.1ml/kg) para tubo endotraqueal. Shock hipotensivo 0.1 - 1 mg/kg Infusión continua. 0.01 mg/kg endovenosa intramuscular
','mg/kg', 'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Adrenalina	FA 1ml: 1mg (Vitrartato)', 0.01, 1, false, 'EV inf. continua', 1, 24,'mg', 'Paro cardiorespiratorio, bradicardia: 0.01 mg/kg (0.1 ml/kg) cada 3 - 5 min. 0.1 mg/kg (0.1ml/kg) para tubo endotraqueal. Shock hipotensivo 0.1 - 1 mg/kg Infusión continua. 0.01 mg/kg endovenosa intramuscular
','mg/kg', 'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Adrenalina	FA 1ml: 1mg (Vitrartato)', 0.01, 1, false, 'Intramuscular', 1, 24,'mg', 'Paro cardiorespiratorio, bradicardia: 0.01 mg/kg (0.1 ml/kg) cada 3 - 5 min. 0.1 mg/kg (0.1ml/kg) para tubo endotraqueal. Shock hipotensivo 0.1 - 1 mg/kg Infusión continua. 0.01 mg/kg endovenosa intramuscular
','mg/kg', 'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Adrenalina	FA 1ml: 1mg (Vitrartato)', 0.01, 1, false, 'Endotraqueal', 1, 24,'mg', 'Paro cardiorespiratorio, bradicardia: 0.01 mg/kg (0.1 ml/kg) cada 3 - 5 min. 0.1 mg/kg (0.1ml/kg) para tubo endotraqueal. Shock hipotensivo 0.1 - 1 mg/kg Infusión continua. 0.01 mg/kg endovenosa intramuscular
','mg/kg', 'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Adrenalina	FA 1ml: 1mg (Vitrartato)', 0.01, 1, false, 'Intraosea', 1, 24,'mg', 'Paro cardiorespiratorio, bradicardia: 0.01 mg/kg (0.1 ml/kg) cada 3 - 5 min. 0.1 mg/kg (0.1ml/kg) para tubo endotraqueal. Shock hipotensivo 0.1 - 1 mg/kg Infusión continua. 0.01 mg/kg endovenosa intramuscular
','mg/kg', 'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Albumina 20%	Vial 50ml: 10g', 200, 1, false, 'EV directa', 1, 24,'g', '2 a 5ml/kg (200 a 500mg/kg). Hipoproteinemia E.V.: 0.5-1g/kg/dosis. Hipovolemia E.V.:0.5-1g/kg/dosis. Síndrome Nefrótico: 0.25-1g/kg/dosis
','mg/kg', 'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Albumina 20%	Vial 50ml: 10g', 200, 6, false, 'EV inf. intermitente', 1, 24,'g', '2 a 5ml/kg (200 a 500mg/kg). Hipoproteinemia E.V.: 0.5-1g/kg/dosis. Hipovolemia E.V.:0.5-1g/kg/dosis. Síndrome Nefrótico: 0.25-1g/kg/dosis
','mg/kg', 'mg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Amikacina  Vial 2ml:100mg', 10, 10, false, 'EV inf. intermitente', 100, 24, 'mg','Monodosis: 10-15mg/kg   Mutidosis:5-7.5mg/kg
 ','mg/kg', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Amikacina  Vial 2ml:100mg', 10, 10, false, 'EV inf. continua', 100, 24, 'mg','Monodosis: 10-15mg/kg   Mutidosis:5-7.5mg/kg
 ','mg/kg', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Amikacina  Vial 2ml:100mg', 10, 10, false, 'Intramuscular', 100, 24, 'mg','Monodosis: 10-15mg/kg   Mutidosis:5-7.5mg/kg
 ','mg/kg', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Amikacina  Vial 2ml:100mg', 10, 10, false, 'Rectal', 100, 24, 'mg','Monodosis: 10-15mg/kg   Mutidosis:5-7.5mg/kg
 ','mg/kg', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Amikacina  Vial 2ml:500mg', 10, 10, false, 'EV inf. intermitente', 100, 24, 'mg','Monodosis: 10-15mg/kg   Mutidosis:5-7.5mg/kg
 ','mg/kg', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Amikacina  Vial 2ml:500mg', 10, 10, false, 'EV inf. continua', 100, 24, 'mg','Monodosis: 10-15mg/kg   Mutidosis:5-7.5mg/kg
 ','mg/kg', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Amikacina  Vial 2ml:500mg', 10, 10, false, 'Intramuscular', 100, 24, 'mg',' Monodosis: 10-15mg/kg   Mutidosis:5-7.5mg/kg
','mg/kg', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Amikacina  Vial 2ml:500mg', 10, 10, false, 'Rectal', 100, 24, 'mg',' Monodosis: 10-15mg/kg   Mutidosis:5-7.5mg/kg
','mg/kg', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Aminofilina  FA 10ml:250mg', 10, 500, false, 'EV inf. intermitente', 250, 1, 'mg',' Broncoespasmo  EV.:10mg/kg en 20-30min    Infusión contínua: 0.8-mg/kg/hr','mg/kg', 'mg/hr');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Aminofilina  FA 10ml:250mg', 0.8, 500, false, 'EV inf. continua', 250, 1, 'mg','Broncoespasmo  EV.:10mg/kg en 20-30min    Infusión contínua: 0.8-mg/kg/hr','mg/kg/hr', 'mg/hr');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Amiodarona  FA 3ml:150mg', 5, 300, false, 'EV inf. intermitente', 150, 24, 'mg','TSV, TV:5mg/kg (dosis de carga en 20-60min)  Dosis mantención: 2-20mg/kg/día (infusión contínua de 5-15mcg/kg/min)   Paro cardiorrespiratorio: 5mg/kg bolo
 ','mg/kg', 'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Amiodarona  FA 3ml:150mg', 5, 300, false, 'EV directa', 150, 24, 'mg','TSV, TV:5mg/kg (dosis de carga en 20-60min)  Dosis mantención: 2-20mg/kg/día (infusión contínua de 5-15mcg/kg/min)   Paro cardiorrespiratorio: 5mg/kg bolo
 ','mg/kg', 'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Amiodarona  FA 3ml:150mg', 5, 300, false, 'EV inf. continua', 150, 24, 'mg','TSV, TV:5mg/kg (dosis de carga en 20-60min)  Dosis mantención: 2-20mg/kg/día (infusión contínua de 5-15mcg/kg/min)   Paro cardiorrespiratorio: 5mg/kg bolo
 ','mg/kg', 'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ampicilina  Polvo liofilizado 500mg', 50, 200, false, 'EV inf. continua', 500, 6, 'mg','50-100mg/kg/día dividido c/6hrs. Reconstituir en 5ml agua para inyectables.
 ','mg/kg/día', 'mg/kg/día');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ampicilina  Polvo liofilizado 500mg', 50, 30, false, 'EV inf. intermitente', 500, 6, 'mg','50-100mg/kg/día dividido c/6hrs. Reconstituir en 5ml agua para inyectables.
 ','mg/kg/día', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ampicilina  Polvo liofilizado 500mg', 50, 200, false, 'EV directa', 500, 6, 'mg',' 50-100mg/kg/día dividido c/6hrs. Reconstituir en 5ml agua para inyectables.
','mg/kg/día', 'mg/kg/día');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Anfotericina B Complejo lipídico L-ampho Vial 10ml:50mg', 3, 2, false, 'EV directa', 50, 24, 'mg',' ','mg/kg/día', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Anfotericina B Complejo lipídico L-ampho Vial 10ml:50mg', 3, 2, false, 'EV inf. intermitente', 50, 24, 'mg',' ','mg/kg/día', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Anfotericina B Deocoxilato Polvo liofilizado 50mg', 0.25, 0.5, false, 'EV inf. intermitente', 50, 24, 'mg','0.25-1mg/kg/día    En días alternos: 1-1.5mg/kg/dosis
 ','mg/kg/día', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Anidulafungina Polvo liofilizado 100mg ', 3, 200, false, 'EV inf. intermitente', 50, 24, 'mg','Dosis carga: 3mg/kg/día en EV lenta; Mantención: 1.5mg/kg/día en EV lenta
 ','mg/kg/día', 'mg/día');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Atracurio FA 2.5ml:25mg', 0.3, 0.5, false, 'EV directa', 25, 24, 'mg',' 0.3_0.5mg/kg dosis; en BIC 5-10mcg/kg/min
','mg/kg', 'mg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Atracurio FA 2.5ml:25mg', 5, 10, false, 'EV inf. continua', 25, 24, 'mg','0.3_0.5mg/kg dosis; en BIC 5-10mcg/kg/min
 ','mcg/kg/min', 'mcg/kg/min');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Atropina FA 1ml:1mg', 0.02, 1, false, 'EV inf. continua', 1, 24, 'mg',' Bradicardia: 0.02mg/kg   Intoxicación organofosforados o carbamatos: En menores de 12 años 0.02-0,05mg/kg c/30min hasta reducir síntomas muscarínico. En mayores de 12 años 0.05mg/kg, luego 1-2mg c/30min. Hasta revertir síntomas muscarínicos. Secuencia intubación rápida: 0.01-0.02mg/kg
','mg/kg', 'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Atropina FA 1ml:1mg', 0.02, 1, false, 'Endotraqueal', 1, 24, 'mg','Bradicardia: 0.02mg/kg   Intoxicación organofosforados o carbamatos: En menores de 12 años 0.02-0,05mg/kg c/30min hasta reducir síntomas muscarínico. En mayores de 12 años 0.05mg/kg, luego 1-2mg c/30min. Hasta revertir síntomas muscarínicos. Secuencia intubación rápida: 0.01-0.02mg/kg
 ','mg/kg', 'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Betametasona FA 1ml:4mg sodio fosfato', 0.2, 4, false, 'EV directa', 4, 8,'mg',' ','mg/kg/dosis', 'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Betametasona FA 1ml:4mg sodio fosfato', 0.2, 4, false, 'EV inf. continua', 4, 8,'mg',' ','mg/kg/dosis', 'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Betametasona FA 1ml:4mg sodio fosfato', 0.2, 4, false, 'EV inf. intermitente', 4, 8,'mg',' ','mg/kg/dosis', 'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Betametasona FA 1ml:4mg sodio fosfato', 0.2, 4, false, 'Intramuscular', 4, 8,'mg',' ','mg/kg/dosis', 'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Betametasona FA 1ml:4mg sodio fosfato', 0.2, 4, false, 'Oral', 4, 8,'mg',' ','mg/kg/dosis', 'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Clorfenamina FA 10mg/ml maleato', 87.5, 40, false, 'EV directa', 10, 6,'mg',' ','mcg/kg/dosis', 'mg/día');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Clorfenamina FA 10mg/ml maleato', 87.5, 40, false, 'EV inf. intermitente', 10, 6,'mg',' ','mcg/kg/dosis', 'mg/día');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Clorfenamina FA 10mg/ml maleato', 87.5, 40, false, 'Intramuscular', 10, 6,'mg',' ','mcg/kg/dosis', 'mg/día');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Clindamicina FA 4ml:600mg', 0, 30, false, 'EV inf. intermitente', 600, 6,'mg',' ','mg/kg/día', 'mg/kg/día');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Clindamicina FA 4ml:600mg', 0, 30, false, 'Intramuscular', 600, 6,'mg',' ','mg/kg/día', 'mg/kg/día');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Clindamicina FA 4ml:600mg', 0, 30, false, 'Vaginal', 600, 6,'mg',' ','mg/kg/día', 'mg/kg/día');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Clindamicina FA 4ml:600mg', 0, 30, false, 'Oral', 600, 6,'mg',' ','mg/kg/día', 'mg/kg/día');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ciprofloxacino inyectable 100ml:200mg', 0, 20, false, 'EV inf. intermitente', 200, 8,'mg','20-30mg/kg/día c/12hrs. Infecciones severas c/8hrs
 ','mg/kg/día', 'mg/kg/día');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ciclofosfamida Polvo liofilizado 200mg', 0, 200, false, 'EV inf. continua', 200, 1,'mg',' Quimioterapia: 200-500mg/m2/dosis  Lupus eritrematoso sistémico: 500-750mg/m2/dosis (1 vez c/6m)  Pulsos artritis juvenil ideopática; 10mg/kg EV cada 2 semanas.
','mg/dosis', 'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ciclofosfamida Polvo liofilizado 200mg', 0, 200, false, 'EV inf. intermitente', 200, 1,'mg','Quimioterapia: 200-500mg/m2/dosis  Lupus eritrematoso sistémico: 500-750mg/m2/dosis (1 vez c/6m)  Pulsos artritis juvenil ideopática; 10mg/kg EV cada 2 semanas.
 ','mg/dosis', 'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ciclofosfamida Polvo liofilizado 200mg', 0, 200, false, 'Oral', 200, 1,'mg',' Quimioterapia: 200-500mg/m2/dosis  Lupus eritrematoso sistémico: 500-750mg/m2/dosis (1 vez c/6m)  Pulsos artritis juvenil ideopática; 10mg/kg EV cada 2 semanas.
','mg/dosis', 'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ciclofosfamida Polvo liofilizado 500mg', 0, 200, false, 'EV inf. continua', 500, 1,'mg',' Quimioterapia: 200-500mg/m2/dosis  Lupus eritrematoso sistémico: 500-750mg/m2/dosis (1 vez c/6m)  Pulsos artritis juvenil ideopática; 10mg/kg EV cada 2 semanas.
','mg/dosis', 'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ciclofosfamida Polvo liofilizado 500mg', 0, 200, false, 'EV inf. intermitente', 500, 1,'mg','Quimioterapia: 200-500mg/m2/dosis  Lupus eritrematoso sistémico: 500-750mg/m2/dosis (1 vez c/6m)  Pulsos artritis juvenil ideopática; 10mg/kg EV cada 2 semanas.
 ','mg/dosis', 'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ciclofosfamida Polvo liofilizado 500mg', 0, 200, false, 'Oral', 500, 1,'mg','Quimioterapia: 200-500mg/m2/dosis  Lupus eritrematoso sistémico: 500-750mg/m2/dosis (1 vez c/6m)  Pulsos artritis juvenil ideopática; 10mg/kg EV cada 2 semanas.
 ','mg/dosis', 'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ciclofosfamida Polvo liofilizado 1000mg', 0, 200, false, 'EV inf. continua', 1000, 1,'mg',' Quimioterapia: 200-500mg/m2/dosis  Lupus eritrematoso sistémico: 500-750mg/m2/dosis (1 vez c/6m)  Pulsos artritis juvenil ideopática; 10mg/kg EV cada 2 semanas.
','mg/dosis', 'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ciclofosfamida Polvo liofilizado 1000mg', 0, 200, false, 'EV inf. intermitente', 1000, 1,'mg','Quimioterapia: 200-500mg/m2/dosis  Lupus eritrematoso sistémico: 500-750mg/m2/dosis (1 vez c/6m)  Pulsos artritis juvenil ideopática; 10mg/kg EV cada 2 semanas.
 ','mg/dosis', 'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ciclofosfamida Polvo liofilizado 1000mg', 0, 200, false, 'Oral', 1000, 1,'mg',' Quimioterapia: 200-500mg/m2/dosis  Lupus eritrematoso sistémico: 500-750mg/m2/dosis (1 vez c/6m)  Pulsos artritis juvenil ideopática; 10mg/kg EV cada 2 semanas.
','mg/dosis', 'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ceftriaxona Polvo liofilizado 1000mg sal sódica', 50, 4, false, 'EV inf. intermitente', 1000, 12,'mg',' 50-100mg/kg/día c/12-24hrs. Meningitis 100mg/kg/día c/24hrs.
','mg/kg/día', 'gr/día');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ceftriaxona Polvo liofilizado 1000mg sal sódica', 50, 4, false, 'EV inf. continua', 1000, 12,'mg',' 50-100mg/kg/día c/12-24hrs. Meningitis 100mg/kg/día c/24hrs.
','mg/kg/día', 'gr/día');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ceftriaxona Polvo liofilizado 1000mg sal sódica', 50, 4, false, 'Intramuscular', 1000, 12,'mg','50-100mg/kg/día c/12-24hrs. Meningitis 100mg/kg/día c/24hrs.
 ','mg/kg/día', 'gr/día');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ceftazidima FA Polvo liofilizado 1000mg pentahidrato', 15, 2, false, 'EV directa', 1000, 8,'mg',' 15-25mg/kg/dosis c/8hrs.  Infección severa 50mg/kg/dosis c/8hrs 
','mg/kg/dosis', 'gr/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ceftazidima FA Polvo liofilizado 1000mg pentahidrato', 15, 2, false, 'EV inf. continua', 1000, 8,'mg',' 15-25mg/kg/dosis c/8hrs.  Infección severa 50mg/kg/dosis c/8hrs 
','mg/kg/dosis', 'gr/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ceftazidima FA Polvo liofilizado 1000mg pentahidrato', 15, 2, false, 'Intramuscular', 1000, 8,'mg','15-25mg/kg/dosis c/8hrs.  Infección severa 50mg/kg/dosis c/8hrs 
 ','mg/kg/dosis', 'gr/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ceftazidima FA Polvo liofilizado 1000mg pentahidrato', 15, 2, false, 'EV inf. intermitente', 1000, 8,'mg','15-25mg/kg/dosis c/8hrs.  Infección severa 50mg/kg/dosis c/8hrs 
 ','mg/kg/dosis', 'gr/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cefotaxima Polvo liofilizado 1000mg', 150, 100, false, 'EV directa', 1000, 6,'mg',' 150mg/kg/día c/6hrs.  Meningitis o infecciones severas 200-300mg/kg/día c/6hrs
','mg/kg/día', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cefotaxima Polvo liofilizado 1000mg', 150, 100, false, 'EV inf. intermitente', 1000, 6,'mg','150mg/kg/día c/6hrs.  Meningitis o infecciones severas 200-300mg/kg/día c/6hrs
 ','mg/kg/día', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cefotaxima Polvo liofilizado 1000mg', 150, 100, false, 'EV inf. continua', 1000, 6,'mg','150mg/kg/día c/6hrs.  Meningitis o infecciones severas 200-300mg/kg/día c/6hrs
 ','mg/kg/día', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cefotaxima Polvo liofilizado 1000mg', 150, 100, false, 'Intramuscular', 1000, 6,'mg','150mg/kg/día c/6hrs.  Meningitis o infecciones severas 200-300mg/kg/día c/6hrs
 ','mg/kg/día', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cefoperazona-Sulbactam Polvo liofilizado 1000mg', 20, 160, false, 'EV directa', 1000, 6,'mg','20-40mg cefoperazona/kg/día divididos C/6-8hrs.  Infecciones severas: Hasta 160mg/kg/día divididos c/6-8hrs.
 ','mg/kg/día', 'mg/kg/día');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cefoperazona-Sulbactam Polvo liofilizado 1000mg', 20, 160, false, 'EV inf. intermitente', 1000, 6,'mg',' 20-40mg cefoperazona/kg/día divididos C/6-8hrs.  Infecciones severas: Hasta 160mg/kg/día divididos c/6-8hrs.
','mg/kg/día', 'mg/kg/día');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cefoperazona-Sulbactam Polvo liofilizado 1000mg', 20, 160, false, 'EV inf. continua', 1000, 6,'mg','20-40mg cefoperazona/kg/día divididos C/6-8hrs.  Infecciones severas: Hasta 160mg/kg/día divididos c/6-8hrs.
 ','mg/kg/día', 'mg/kg/día');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cefoperazona-Sulbactam Polvo liofilizado 1000mg', 20, 160, false, 'Intramuscular', 1000, 6,'mg','20-40mg cefoperazona/kg/día divididos C/6-8hrs.  Infecciones severas: Hasta 160mg/kg/día divididos c/6-8hrs.
 ','mg/kg/día', 'mg/kg/día');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cefoperazona-Sulbactam Polvo liofilizado 500mg', 20, 160, false, 'EV directa', 500, 6,'mg','20-40mg cefoperazona/kg/día divididos C/6-8hrs.  Infecciones severas: Hasta 160mg/kg/día divididos c/6-8hrs.
 ','mg/kg/día', 'mg/kg/día');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cefoperazona-Sulbactam Polvo liofilizado 500mg', 20, 160, false, 'EV directa', 500, 6,'mg',' 20-40mg cefoperazona/kg/día divididos C/6-8hrs.  Infecciones severas: Hasta 160mg/kg/día divididos c/6-8hrs.
','mg/kg/día', 'mg/kg/día');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cefoperazona-Sulbactam Polvo liofilizado 500mg', 20, 160, false, 'EV directa', 500, 6,'mg',' 20-40mg cefoperazona/kg/día divididos C/6-8hrs.  Infecciones severas: Hasta 160mg/kg/día divididos c/6-8hrs.
','mg/kg/día', 'mg/kg/día');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cefoperazona-Sulbactam Polvo liofilizado 500mg', 20, 160, false, 'EV directa', 500, 6,'mg','20-40mg cefoperazona/kg/día divididos C/6-8hrs.  Infecciones severas: Hasta 160mg/kg/día divididos c/6-8hrs.
 ','mg/kg/día', 'mg/kg/día');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cefepime Polvo liofilizado 1000mg', 50, 2, false, 'EV directa', 1000, 8,'mg',' ','mg/kg/dosis', 'gr/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cefepime Polvo liofilizado 1000mg', 50, 2, false, 'EV inf. continua', 1000, 8,'mg',' ','mg/kg/dosis', 'gr/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cefepime Polvo liofilizado 1000mg', 50, 2, false, 'EV inf. intermitente', 1000, 8,'mg',' ','mg/kg/dosis', 'gr/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cefepime Polvo liofilizado 1000mg', 50, 2, false, 'Intramuscular', 1000, 8,'mg',' ','mg/kg/dosis', 'gr/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cefepime Polvo liofilizado 2000mg', 50, 2, false, 'EV directa', 2000, 8,'mg',' ','mg/kg/dosis', 'gr/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cefepime Polvo liofilizado 2000mg', 50, 2, false, 'EV inf. continua', 2000, 8,'mg',' ','mg/kg/dosis', 'gr/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cefepime Polvo liofilizado 2000mg', 50, 2, false, 'EV inf. intermitente', 2000, 8,'mg',' ','mg/kg/dosis', 'gr/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cefepime Polvo liofilizado 2000mg', 50, 2, false, 'Intramuscular', 2000, 8,'mg',' ','mg/kg/dosis', 'gr/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cefazolina Polvo liofilizado 1000mg sal sódica', 10, 6, false, 'EV directa', 1000, 6,'mg','10-60mg/kg/día  Profilaxis quirúrgica: 50mg/kg/dosis 30 previos a incisión de piel.  Infección severa: 100mg/kg/día c/6-8hrs
 ','mg/kg/día', 'gr/día');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cefazolina Polvo liofilizado 1000mg sal sódica', 10, 6, false, 'EV inf. intermitente', 1000, 6,'mg','10-60mg/kg/día  Profilaxis quirúrgica: 50mg/kg/dosis 30 previos a incisión de piel.  Infección severa: 100mg/kg/día c/6-8hrs
 ','mg/kg/día', 'gr/día');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cefazolina Polvo liofilizado 1000mg sal sódica', 10, 6, false, 'Intramuscular', 1000, 6,'mg',' 10-60mg/kg/día  Profilaxis quirúrgica: 50mg/kg/dosis 30 previos a incisión de piel.  Infección severa: 100mg/kg/día c/6-8hrs
','mg/kg/día', 'gr/día');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Caspofungina Polvo liofilizado 50mg', 70, 0.5, false, 'EV inf. intermitente', 50, 1,'mg','Dosis carga: 70mg/m2/día en infusión EV. Mantención: 50mg/m2/día
 ','mg/día', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Caspofungina Polvo liofilizado 70mg', 70, 0.5, false, 'EV inf. intermitente', 70, 1,'mg',' Dosis carga: 70mg/m2/día en infusión EV. Mantención: 50mg/m2/día
','mg/día', 'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Cloxacilina de 500mg',           100        , 200  ,     false  , 'EV directa'  ,  500           , 4              , 'mg'  , 'Suero fisiológico (recomendado), suero glucosado 5%'  , 'mg/kg'    ,    'mg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Cloxacilina de 500mg',           100        , 200  ,     false  , 'EV inf. intermitente'  ,  500           , 4              , 'mg'  , 'Suero fisiológico (recomendado), suero glucosado 5%'  , 'mg/kg'    ,    'mg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Cloxacilina de 500mg',           100        , 200  ,     false  , 'Intramuscular'  ,  500           , 4              , 'mg'  , 'Suero fisiológico (recomendado), suero glucosado 5%'  , 'mg/kg'    ,    'mg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Colistimetato',           1000000        , 2000000  ,     false  , 'EV directa'          ,  1000000         , 6                , 'UI'  , 'Dosis:50.000-75.000 UI/kg/día   Adolescentes: 1.000.000-3.000.000 UI cada 8hrs'  , 'UI/kg' ,    'UI/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Colistimetato',           1000000        , 2000000  ,     false  , 'EV inf. intermitente'          ,  1000000         , 6                , 'UI'  , 'Dosis:50.000-75.000 UI/kg/día   Adolescentes: 1.000.000-3.000.000 UI cada 8hrs'  , 'UI/kg' ,    'UI/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Dantroleno polvo liofilizado de 20mg', 1    , 10 ,     false  , 'EV inf. intermitente',  20         , 6                , 'mg'  , 'Dosis:Inicial 1mg/kg,, luego 1-2.5mg/kg c/6hrs'  , 'mg/kg' ,    'mg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Dantroleno polvo liofilizado de 20mg', 1    , 10 ,     false  , 'EV directa',  20         , 6                , 'mg'  , 'Dosis:Inicial 1mg/kg,, luego 1-2.5mg/kg c/6hrs'  , 'mg/kg' ,    'mg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Desmopresina 1ml de 15 mcg', 2               , 0.5 ,     false  , 'EV directa'           ,       15         , 12                , 'mcg'  , 'Dosis:Diabetes insípida. Niños <12a: 0.1-1mcg/día. Niños >12a:2-4mcg/día'  , 'mcg/dia' ,    'mcg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Desmopresina 1ml de 15 mcg', 2               , 0.5 ,     false  , 'EV inf. intermitente'           ,       15         , 12                , 'mcg'  , 'Dosis:Diabetes insípida. Niños <12a: 0.1-1mcg/día. Niños >12a:2-4mcg/día'  , 'mcg/dia' ,    'mcg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Desmopresina 1ml de 15 mcg', 2               , 0.5 ,     false  , 'Oral'           ,       15         , 12                , 'mcg'  , 'Dosis:Diabetes insípida. Niños <12a: 0.1-1mcg/día. Niños >12a:2-4mcg/día'  , 'mcg/dia' ,    'mcg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Desmopresina 1ml de 15 mcg', 2               , 0.5 ,     false  , 'Intranasal'           ,       15         , 12                , 'mcg'  , 'Dosis:Diabetes insípida. Niños <12a: 0.1-1mcg/día. Niños >12a:2-4mcg/día'  , 'mcg/dia' ,    'mcg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Dexametasona FA 1ml de 4mg', 0.5               , 10 ,     false  , 'EV inf. intermitente'           ,       15         , 12                , 'mcg'  , 'Dosis:Neonatos: Edema de la vía aérea o extubacion: 0,25 mg/kg/día (4 horas previa extubacion), cada 8 horas por tres dosis. Displasia broncopulmonar: 0,5 mg/kg/día, cada 12 horas por tres días. Niños: Edema vía aérea o extubación: 0,5 - 2 mg/kg/día.'  , 'mg/kg' ,    'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Dexametasona FA 1ml de 4mg', 0.5               , 10 ,     false  , 'EV inf. intermitente'           ,       15         , 12                , 'mcg'  , 'Dosis:Neonatos: Edema de la vía aérea o extubacion: 0,25 mg/kg/día (4 horas previa extubacion), cada 8 horas por tres dosis. Displasia broncopulmonar: 0,5 mg/kg/día, cada 12 horas por tres días. Niños: Edema vía aérea o extubación: 0,5 - 2 mg/kg/día.'  , 'mg/kg' ,    'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Dexametasona FA 1ml de 4mg', 0.5               , 10 ,     false  , 'Intramuscular'           ,       15         , 12                , 'mcg'  , 'Dosis:Neonatos: Edema de la vía aérea o extubacion: 0,25 mg/kg/día (4 horas previa extubacion), cada 8 horas por tres dosis. Displasia broncopulmonar: 0,5 mg/kg/día, cada 12 horas por tres días. Niños: Edema vía aérea o extubación: 0,5 - 2 mg/kg/día.'  , 'mg/kg' ,    'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Dexametasona FA 1ml de 4mg', 0.5               , 10 ,     false  , 'Oral'           ,       15         , 12                , 'mcg'  , 'Dosis:Neonatos: Edema de la vía aérea o extubacion: 0,25 mg/kg/día (4 horas previa extubacion), cada 8 horas por tres dosis. Displasia broncopulmonar: 0,5 mg/kg/día, cada 12 horas por tres días. Niños: Edema vía aérea o extubación: 0,5 - 2 mg/kg/día.'  , 'mg/kg' ,    'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Dexametasona FA 1ml de 4mg', 0.5               , 10 ,     false  , 'Subcutánea'           ,       15         , 12                , 'mcg'  , 'Dosis:Neonatos: Edema de la vía aérea o extubacion: 0,25 mg/kg/día (4 horas previa extubacion), cada 8 horas por tres dosis. Displasia broncopulmonar: 0,5 mg/kg/día, cada 12 horas por tres días. Niños: Edema vía aérea o extubación: 0,5 - 2 mg/kg/día.'  , 'mg/kg' ,    'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Dexametasona FA 1ml de 4mg', 0.5               , 10 ,     false  , 'Intraarticular'           ,       15         , 12                , 'mcg'  , 'Dosis:Neonatos: Edema de la vía aérea o extubacion: 0,25 mg/kg/día (4 horas previa extubacion), cada 8 horas por tres dosis. Displasia broncopulmonar: 0,5 mg/kg/día, cada 12 horas por tres días. Niños: Edema vía aérea o extubación: 0,5 - 2 mg/kg/día.'  , 'mg/kg' ,    'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Dexametasona FA 1ml de 4mg', 0.5               , 10 ,     false  , 'Intratecal'           ,       15         , 12                , 'mcg'  , 'Dosis:Neonatos: Edema de la vía aérea o extubacion: 0,25 mg/kg/día (4 horas previa extubacion), cada 8 horas por tres dosis. Displasia broncopulmonar: 0,5 mg/kg/día, cada 12 horas por tres días. Niños: Edema vía aérea o extubación: 0,5 - 2 mg/kg/día.'  , 'mg/kg' ,    'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Diazepam FA 2ml de 10 mg',  0.5               , 10 ,     false  , 'Intratecal'           ,       15         , 12                , 'mcg'  , 'Dosis:Neonatos: Edema de la vía aérea o extubacion: 0,25 mg/kg/día (4 horas previa extubacion), cada 8 horas por tres dosis. Displasia broncopulmonar: 0,5 mg/kg/día, cada 12 horas por tres días. Niños: Edema vía aérea o extubación: 0,5 - 2 mg/kg/día.'  , 'mg/kg' ,    'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Diazepam FA 2ml de 10 mg'  , 0.1             , 20 ,     false  , 'EV inf. continua'    ,       10         , 10                , 'mg'  , 'Dosis: 0.1-0.3mg/kg/dosis'  , 'mg/kg' ,    'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Diazepam FA 2ml de 10 mg'  , 0.1             , 20 ,     false  , 'Intramuscular'    ,       10         , 10                , 'mg'  , 'Dosis: 0.1-0.3mg/kg/dosis'  , 'mg/kg' ,    'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Diazepam FA 2ml de 10 mg'  , 0.1             , 20 ,     false  , 'Oral'    ,       10         , 10                , 'mg'  , 'Dosis: 0.1-0.3mg/kg/dosis'  , 'mg/kg' ,    'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Diazepam FA 2ml de 10 mg'  , 0.1             , 20 ,     false  , 'Rectal'    ,       10         , 10                , 'mg'  , 'Dosis: 0.1-0.3mg/kg/dosis'  , 'mg/kg' ,    'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Dobutamina FA 5ML DE 250mg'  , 2.5             , 1500 ,   false  , 'EV inf. continua' ,       250         , 2.5                , 'mcg'  , 'Dosis: Concentración máx.:1500mcg/ml-3000mcg/ml', 'mcg/kg' ,    'mcg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Dobutamina FA 5ML DE 250mg'  , 2.5             , 1500 ,   false  , 'Intraosea' ,       250         , 2.5                , 'mcg'  , 'Dosis: Concentración máx.:1500mcg/ml-3000mcg/ml', 'mcg/kg' ,    'mcg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Domperidona 2ml de 10mg'  , 0.2             , 10 ,   false  , 'EV inf. intermitente' ,       10         ,     8                , 'mg'  , 'Dosis: Concentración máx.:1500mcg/ml-3000mcg/ml', 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Domperidona 2ml de 10mg'  , 0.2             , 10 ,   false  , 'Intramuscular' ,       10         ,     8                , 'mg'  , 'Dosis: Concentración máx.:1500mcg/ml-3000mcg/ml', 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Domperidona 2ml de 10mg'  , 0.2             , 10 ,   false  , 'Oral' ,       10         ,     8                , 'mg'  , 'Dosis: Concentración máx.:1500mcg/ml-3000mcg/ml', 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Dopamina FA 5ml de 200mg', 1                  , 50 ,   false  , 'EV inf. continua' ,           200         ,     12                , 'mcg'  , 'Dosis: 1-20mcg/kg/min'    , 'mcg/kg' ,    'mcg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Fenitoina FA 5ml de 250mg', 15                , 20 ,   false  , 'Oral' ,       250         ,     0                , 'mg'  , 'Dosis: Status epiléptico EV Carga: 15-20mg/kg/dosis   Anticonvulsante: Carga 15-20mg/kg, mantención igual que carga.'    , 'mg/kg' ,    'mg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Fenitoina FA 5ml de 250mg', 15                , 20 ,   false  , 'EV inf. continua' ,       250         ,     0                , 'mg'  , 'Dosis: Status epiléptico EV Carga: 15-20mg/kg/dosis   Anticonvulsante: Carga 15-20mg/kg, mantención igual que carga.'    , 'mg/kg' ,    'mg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Fenorbarbital FA 1ml de 200mg', 15            , 60 ,   false  , 'EV directa' ,       200         ,     8                , 'mg'  , 'Dosis: Anticonvulsivante: Status epiléptico: Dosis de carga: E.V.: 15 - 20 mg/kg (dosis máxima 1000 mg, puede repetirse la dosis después de 15 minutos con tope máximo de 40 mg/kg).'    , 'mg/kg' ,    'mg/min');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Fenorbarbital FA 1ml de 200mg', 15            , 60 ,   false  , 'Intramuscular' ,       200         ,     8      , 'mg'  , 'Dosis: Anticonvulsivante: Status epiléptico: Dosis de carga: E.V.: 15 - 20 mg/kg (dosis máxima 1000 mg, puede repetirse la dosis después de 15 minutos con tope máximo de 40 mg/kg).'    , 'mg/kg' ,    'mg/min');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Fenoterol FA 10ml de 0.5mg', 0.1            , 0 ,   false  , 'EV inf. continua'       ,       0.5         ,     0               , 'mcg'  , 'Dosis: 0.1-0.3mcg/kg/min'    , 'mcg/kg' ,    'mcg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Fenoterol FA 10ml de 0.5mg', 0.1            , 0 ,   false  , 'Inhalatoria'       ,       0.5         ,     0               , 'mcg'  , 'Dosis: 0.1-0.3mcg/kg/min'    , 'mcg/kg' ,    'mcg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Fentanyl FA 2ml de 0.1mg', 1                   , 0 ,   false  , 'EV inf. continua'       ,       0.1         ,     0               , 'mcg'  , 'Dosis: Sedación Bolo: 1 - 2 mcg/kg. Infusión: 2 - 4 mcg/kg/hr (menores de 10 kg: 100 mcg/kg /50 cc SG5% a 1 - 2 cc/hr) (mayores de 10 kg: 50 mcg/ml a 0,04 - 0,08 ml/hr). '    , 'mcg/kg' ,    'mcg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Fentanyl FA 2ml de 0.1mg', 1                   , 0 ,   false  , 'EV directa'       ,       0.1         ,     0               , 'mcg'  , 'Dosis: Sedación Bolo: 1 - 2 mcg/kg. Infusión: 2 - 4 mcg/kg/hr (menores de 10 kg: 100 mcg/kg /50 cc SG5% a 1 - 2 cc/hr) (mayores de 10 kg: 50 mcg/ml a 0,04 - 0,08 ml/hr). '    , 'mcg/kg' ,    'mcg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Fentanyl FA 2ml de 0.1mg', 1                   , 0 ,   false  , 'EV inf. continua'       ,       0.1         ,     0               , 'mcg'  , 'Dosis: Sedación Bolo: 1 - 2 mcg/kg. Infusión: 2 - 4 mcg/kg/hr (menores de 10 kg: 100 mcg/kg /50 cc SG5% a 1 - 2 cc/hr) (mayores de 10 kg: 50 mcg/ml a 0,04 - 0,08 ml/hr). '    , 'mcg/kg' ,    'mcg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Fentanyl FA 2ml de 0.1mg', 1                   , 0 ,   false  , 'Intramuscular'       ,       0.1         ,     0               , 'mcg'  , 'Dosis: Sedación Bolo: 1 - 2 mcg/kg. Infusión: 2 - 4 mcg/kg/hr (menores de 10 kg: 100 mcg/kg /50 cc SG5% a 1 - 2 cc/hr) (mayores de 10 kg: 50 mcg/ml a 0,04 - 0,08 ml/hr). '    , 'mcg/kg' ,    'mcg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Fentanyl FA 2ml de 0.1mg', 1                   , 0 ,   false  , 'Epidural'       ,       0.1         ,     0               , 'mcg'  , 'Dosis: Sedación Bolo: 1 - 2 mcg/kg. Infusión: 2 - 4 mcg/kg/hr (menores de 10 kg: 100 mcg/kg /50 cc SG5% a 1 - 2 cc/hr) (mayores de 10 kg: 50 mcg/ml a 0,04 - 0,08 ml/hr). '    , 'mcg/kg' ,    'mcg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Fentanyl FA 2ml de 0.1mg', 1                   , 0 ,   false  , 'Transdérmico'       ,       0.1         ,     0               , 'mcg'  , 'Dosis: Sedación Bolo: 1 - 2 mcg/kg. Infusión: 2 - 4 mcg/kg/hr (menores de 10 kg: 100 mcg/kg /50 cc SG5% a 1 - 2 cc/hr) (mayores de 10 kg: 50 mcg/ml a 0,04 - 0,08 ml/hr). '    , 'mcg/kg' ,    'mcg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Fitomenadiona FA 1ml de 10mg', 0.5             , 10 ,   false  , 'EV inf. continua'       ,       10         ,     0               , 'mg'  , 'Dosis:0.5mg/kg/dosis'    , 'mg/kg' ,    'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Fitomenadiona FA 1ml de 10mg', 0.5             , 10 ,   false  , 'EV directa'       ,       10         ,     0               , 'mg'  , 'Dosis:0.5mg/kg/dosis'    , 'mg/kg' ,    'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Fitomenadiona FA 1ml de 10mg', 0.5             , 10 ,   false  , 'Oral'       ,       10         ,     0               , 'mg'  , 'Dosis:0.5mg/kg/dosis'    , 'mg/kg' ,    'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Fluconazol Viaflex 100ml de 200mg', 6             , 200 ,   false  , 'EV inf. intermitente' ,       200     ,     24               , 'mg'  , 'Dosis:Dosis carga: 6 - 12 mg/kg/día en infusión E.V. lenta en una dosis diaria. Dosis de mantención en menores de 12 años: 12 mg/kg/día.'    , 'mg/kg' ,    'mg/hr');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Flumazenil FA de 0.5mg/5ml', 0.01             , 0 ,   false  , 'EV directa'              ,     200         ,     24             , 'mg'  , 'Dosis:Niños mayores de 1 año: revertir la sedación central inducida por benzodiacepinas, dosis inicial recomendada es de 0,01 mg/kg (hasta 0,2 mg)'    , 'mg/kg' ,    'mg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Flumazenil FA de 0.5mg/5ml', 0.01         , 0 ,   false  , 'EV inf. continua'              ,     200         ,     24             , 'mg'  , 'Dosis:Niños mayores de 1 año: revertir la sedación central inducida por benzodiacepinas, dosis inicial recomendada es de 0,01 mg/kg (hasta 0,2 mg)'    , 'mg/kg' ,    'mg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Furosemida FA 1ml de 20mg', 0.5             , 120 ,   false  , 'EV directa'              ,     20         ,     6             , 'mg'  , 'Dosis:0.5-1mg/kg/dosis c/6hrs  Inf. Continua: 0.1-1mg/kg/hr'    , 'mg/kg' ,    'mg/dia');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Furosemida FA 1ml de 20mg', 0.5             , 120 ,   false  , 'EV inf. continua'              ,     20         ,     6             , 'mg'  , 'Dosis:0.5-1mg/kg/dosis c/6hrs  Inf. Continua: 0.1-1mg/kg/hr'    , 'mg/kg' ,    'mg/dia');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Furosemida FA 1ml de 20mg', 0.5             , 120 ,   false  , 'Oral'              ,     20         ,     6             , 'mg'  , 'Dosis:0.5-1mg/kg/dosis c/6hrs  Inf. Continua: 0.1-1mg/kg/hr'    , 'mg/kg' ,    'mg/dia');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Ganciclovir de 500mg', 5                ,      0      ,   false  , 'EV inf. intermitente' ,     500         ,     0             , 'mg'  , ' Tratamiento de inducción: 5 mg/kg cada 12 horas, durante 14 - 21 días. Tratamiento de mantención: 5 mg/kg cada 24 horas, 7 días a la semana'    , 'mg/kg' ,    'mg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Ganciclovir de 500mg', 5                ,      0      ,   false  , 'Intravitreal' ,     500         ,     0             , 'mg'  , ' Tratamiento de inducción: 5 mg/kg cada 12 horas, durante 14 - 21 días. Tratamiento de mantención: 5 mg/kg cada 24 horas, 7 días a la semana'    , 'mg/kg' ,    'mg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Ganciclovir de 500mg', 5                ,      0      ,   false  , 'Oral' ,     500         ,     0             , 'mg'  , ' Tratamiento de inducción: 5 mg/kg cada 12 horas, durante 14 - 21 días. Tratamiento de mantención: 5 mg/kg cada 24 horas, 7 días a la semana'    , 'mg/kg' ,    'mg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Gentamicina FA 2ml de 80mg', 2.5           ,      0    ,   false  , 'EV inf. intermitente' ,     500         ,     8             , 'mg'  , 'Multidosis: 2.5mg/kg/dosis c/8hrs Monodosis: 7.5mg/kg c/24 hrs'    , 'mg/kg' ,    'mg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Gentamicina FA 2ml de 80mg', 2.5           ,      0    ,   false  , 'Intramuscular' ,     500         ,     8             , 'mg'  , 'Multidosis: 2.5mg/kg/dosis c/8hrs Monodosis: 7.5mg/kg c/24 hrs'    , 'mg/kg' ,    'mg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Gentamicina FA 2ml de 80mg', 2.5           ,      0    ,   false  , 'Intratecal' ,     500         ,     8             , 'mg'  , 'Multidosis: 2.5mg/kg/dosis c/8hrs Monodosis: 7.5mg/kg c/24 hrs'    , 'mg/kg' ,    'mg/kg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Gluconato de calcio FA 10ml de 10%', 200   ,      0    ,   false  , 'EV directa' ,         2         ,     6                   , 'vol%'  , 'Antihipocalcémico: E.V.: 200 a 500 mg de gluconato de calcio/Kg/ día en infusión continua o en 4 dosis divididas.'    , 'mg' ,    'g/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Gluconato de calcio FA 10ml de 10%', 200   ,      0    ,   false  , 'EV inf. continua' ,         2         ,     6                   , 'vol%'  , 'Antihipocalcémico: E.V.: 200 a 500 mg de gluconato de calcio/Kg/ día en infusión continua o en 4 dosis divididas.'    , 'mg' ,    'g/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Gluconato de calcio FA 10ml de 10%', 200   ,      0    ,   false  , 'EV inf. continua' ,         2         ,     6                   , 'vol%'  , 'Antihipocalcémico: E.V.: 200 a 500 mg de gluconato de calcio/Kg/ día en infusión continua o en 4 dosis divididas.'    , 'mg' ,    'g/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Gluconato de calcio FA 10ml de 10%', 200   ,      0    ,   false  , 'EV inf. intermitente' ,         2         ,     6                   , 'vol%'  , 'Antihipocalcémico: E.V.: 200 a 500 mg de gluconato de calcio/Kg/ día en infusión continua o en 4 dosis divididas.'    , 'mg' ,    'g/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Gluconato de calcio FA 10ml de 10%', 200   ,      0    ,   false  , 'Oral' ,         2         ,     6                   , 'vol%'  , 'Antihipocalcémico: E.V.: 200 a 500 mg de gluconato de calcio/Kg/ día en infusión continua o en 4 dosis divididas.'    , 'mg' ,    'g/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Heparina vial 25000UI',         100   ,      0    ,   false  , 'EV directa' ,                      25000         ,     0         , 'UI'  , '1mg: 100 UI. Dosis bajas: 75 UI /kg para comenzar, luego 500 UI /kg en 50 ml suero fisiológico, a 1 - 1,5 ml/hr (10 - 15 UI /kg/hr). '    , 'UI' ,    'UI');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Heparina vial 25000UI',         100   ,      0    ,   false  , 'EV inf. continua' ,                      25000         ,     0         , 'UI'  , '1mg: 100 UI. Dosis bajas: 75 UI /kg para comenzar, luego 500 UI /kg en 50 ml suero fisiológico, a 1 - 1,5 ml/hr (10 - 15 UI /kg/hr). '    , 'UI' ,    'UI');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Heparina vial 25000UI',         100   ,      0    ,   false  , 'EV inf. intermitente' ,                      25000         ,     0         , 'UI'  , '1mg: 100 UI. Dosis bajas: 75 UI /kg para comenzar, luego 500 UI /kg en 50 ml suero fisiológico, a 1 - 1,5 ml/hr (10 - 15 UI /kg/hr). '    , 'UI' ,    'UI');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Heparina vial 25000UI',         100   ,      0    ,   false  , 'Subcutánea' ,                      25000         ,     0         , 'UI'  , '1mg: 100 UI. Dosis bajas: 75 UI /kg para comenzar, luego 500 UI /kg en 50 ml suero fisiológico, a 1 - 1,5 ml/hr (10 - 15 UI /kg/hr). '    , 'UI' ,    'UI');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Hidrocortisona liofilizado 100-500mg',  100   ,    500  ,   false  , 'EV directa' ,           100         ,     24        , 'mg'  , '1Shock: 100 mg/m2 /dosis por una vez, luego fraccionado cada 6 hrs. Reemplazo en estrés moderado: 60 mg/m2 / día.'    , 'mg' ,    'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Hidrocortisona liofilizado 100-500mg',  100   ,    500  ,   false  , 'EV inf. intermitente' ,           100         ,     24        , 'mg'  , '1Shock: 100 mg/m2 /dosis por una vez, luego fraccionado cada 6 hrs. Reemplazo en estrés moderado: 60 mg/m2 / día.'    , 'mg' ,    'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Hidrocortisona liofilizado 100-500mg',  100   ,    500  ,   false  , 'EV inf. continua' ,           100         ,     24        , 'mg'  , '1Shock: 100 mg/m2 /dosis por una vez, luego fraccionado cada 6 hrs. Reemplazo en estrés moderado: 60 mg/m2 / día.'    , 'mg' ,    'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Hidrocortisona liofilizado 100-500mg',  100   ,    500  ,   false  , 'Intramuscular' ,           100         ,     24        , 'mg'  , '1Shock: 100 mg/m2 /dosis por una vez, luego fraccionado cada 6 hrs. Reemplazo en estrés moderado: 60 mg/m2 / día.'    , 'mg' ,    'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('ImipenemCilastatina 500mg',  60           ,    5  ,   false  , 'EV inf. intermitente' ,           500         ,     6        , 'mg'  , 'Dosis: 60-100mg/kg/día c/6-8hr'    , 'mg' ,    'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('ImipenemCilastatina 500mg',  60           ,    5  ,   false  , 'EV inf. continua' ,           500         ,     6        , 'mg'  , 'Dosis: 60-100mg/kg/día c/6-8hr'    , 'mg' ,    'mg/ml');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Insulina 1ml 100UI',       0.1          ,    0  ,   false  , 'EV inf. continua' ,           100         ,     0        , 'UI'  , 'Dosis: 0.1mg/kg/hr'    , 'mg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Insulina 1ml 100UI',       0.1          ,    0  ,   false  , 'Subcutánea' ,           100         ,     0        , 'UI'  , 'Dosis: 0.1mg/kg/hr'    , 'mg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Ketamina 10ml de 500mg',       2          ,    0  ,   false  , 'EV inf. continua' ,           500         ,     0        , 'mg'  , 'Sedación analgesia: 2 - 4 mg/kg por vía I.M. Infusión contínua: 4 mcg/kg/min por vía I.V. Anestesia: 5 - 10mg/kg por vía I.M. 1 - 2 mg/kg/dosis por vía I.V. Infusión 30 mg/50 ml, 1 - 4 ml/hr (10 - 40 mcg/kg/minuto)'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Ketamina 10ml de 500mg',       2          ,    0  ,   false  , 'EV directa' ,           500         ,     0        , 'mg'  , 'Sedación analgesia: 2 - 4 mg/kg por vía I.M. Infusión contínua: 4 mcg/kg/min por vía I.V. Anestesia: 5 - 10mg/kg por vía I.M. 1 - 2 mg/kg/dosis por vía I.V. Infusión 30 mg/50 ml, 1 - 4 ml/hr (10 - 40 mcg/kg/minuto)'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Ketamina 10ml de 500mg',       2          ,    0  ,   false  , 'Intramuscular' ,           500         ,     0        , 'mg'  , 'Sedación analgesia: 2 - 4 mg/kg por vía I.M. Infusión contínua: 4 mcg/kg/min por vía I.V. Anestesia: 5 - 10mg/kg por vía I.M. 1 - 2 mg/kg/dosis por vía I.V. Infusión 30 mg/50 ml, 1 - 4 ml/hr (10 - 40 mcg/kg/minuto)'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Ketamina 10ml de 500mg',       2          ,    0  ,   false  , 'Oral' ,           500         ,     0        , 'mg'  , 'Sedación analgesia: 2 - 4 mg/kg por vía I.M. Infusión contínua: 4 mcg/kg/min por vía I.V. Anestesia: 5 - 10mg/kg por vía I.M. 1 - 2 mg/kg/dosis por vía I.V. Infusión 30 mg/50 ml, 1 - 4 ml/hr (10 - 40 mcg/kg/minuto)'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Ketamina 10ml de 500mg',       2          ,    0  ,   false  , 'Rectal' ,           500         ,     0        , 'mg'  , 'Sedación analgesia: 2 - 4 mg/kg por vía I.M. Infusión contínua: 4 mcg/kg/min por vía I.V. Anestesia: 5 - 10mg/kg por vía I.M. 1 - 2 mg/kg/dosis por vía I.V. Infusión 30 mg/50 ml, 1 - 4 ml/hr (10 - 40 mcg/kg/minuto)'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Ketoprofeno polvo liofilizado 100mg ',  1  ,    4  ,   false  , 'EV inf. continua' ,           100         ,     6        , 'mg'  , 'Dosis: 1-2mg/kg c/6-12hrs'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Ketoprofeno polvo liofilizado 100mg ',  1  ,    4  ,   false  , 'EV inf. intermitente' ,           100         ,     6        , 'mg'  , 'Dosis: 1-2mg/kg c/6-12hrs'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Ketoprofeno polvo liofilizado 100mg ',  1  ,    4  ,   false  , 'Intramuscular' ,           100         ,     6        , 'mg'  , 'Dosis: 1-2mg/kg c/6-12hrs'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Ketoprofeno polvo liofilizado 100mg ',  1  ,    4  ,   false  , 'Oral' ,           100         ,     6        , 'mg'  , 'Dosis: 1-2mg/kg c/6-12hrs'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ketorolaco  30 mg/ml'              ,  0.2  ,    20  ,   false  , 'EV inf. continua' ,           30         ,     0        , 'mg'  , 'Dosis maxima: 20mg/kg/dosis. No extender uso por más de 5 días'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Ketorolaco  30 mg/ml'              ,  0.2  ,    20  ,   false  , 'EV directa' ,           30         ,     0        , 'mg'  , 'Dosis maxima: 20mg/kg/dosis. No extender uso por más de 5 días'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Ketorolaco  30 mg/ml'              ,  0.2  ,    20  ,   false  , 'Intramuscular' ,           30         ,     0        , 'mg'  , 'Dosis maxima: 20mg/kg/dosis. No extender uso por más de 5 días'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Ketorolaco  30 mg/ml'              ,  0.2  ,    20  ,   false  , 'Oral' ,           30         ,     0        , 'mg'  , 'Dosis maxima: 20mg/kg/dosis. No extender uso por más de 5 días'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Labetalol FA 20ml de 100mg'       ,  0.25  ,    20  ,   false  , 'EV inf. continua' ,           100         ,     0.2        , 'mg'  , 'Dosis: 0.25-0.5mg/kg/dosis, c/10 min   Inf, continua 0.4-1mg/kg/hora'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Labetalol FA 20ml de 100mg'     ,  0.25  ,    20  ,   false  , 'EV directa' ,   100    ,     0.2        , 'mg'  , 'Dosis: 0.25-0.5mg/kg/dosis, c/10 min   Inf, continua 0.4-1mg/kg/hora'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Labetalol FA 20ml de 100mg'       ,  0.25  ,    20  ,   false  , 'Oral' ,           100         ,     0.2        , 'mg'  , 'Dosis: 0.25-0.5mg/kg/dosis, c/10 min   Inf, continua 0.4-1mg/kg/hora'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('L-carnitina FA 5ml de 1000mg' ,  50         ,    3  ,   false  , 'EV directa'          ,      1000         ,     4        , 'mg'  , 'Dosis: 50mg/kg/día c/4-6hrs   Post hemodiálisis 10-20mg/kg/dosis, c/10 min   Inf, continua 0.4-1mg/kg/hora'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('L-carnitina FA 5ml de 1000mg' ,  50         ,    3  ,   false  , 'EV inf. continua'          ,      1000         ,     4        , 'mg'  , 'Dosis: 50mg/kg/día c/4-6hrs   Post hemodiálisis 10-20mg/kg/dosis, c/10 min   Inf, continua 0.4-1mg/kg/hora'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('L-carnitina FA 5ml de 1000mg' ,  50         ,    3  ,   false  , 'Intramuscular'          ,      1000         ,     4        , 'mg'  , 'Dosis: 50mg/kg/día c/4-6hrs   Post hemodiálisis 10-20mg/kg/dosis, c/10 min   Inf, continua 0.4-1mg/kg/hora'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('L-carnitina FA 5ml de 1000mg' ,  50         ,    3  ,   false  , 'Oral'          ,      1000         ,     4        , 'mg'  , 'Dosis: 50mg/kg/día c/4-6hrs   Post hemodiálisis 10-20mg/kg/dosis, c/10 min   Inf, continua 0.4-1mg/kg/hora'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Lidocaina FA 5ml de 100mg' ,  1            ,    50  ,   false  , 'EV directa'          ,      100         ,     0             , 'mg'  , 'Dosis: Arritmias Directo: 1 mg/Kg/dosis (máximo 100 mg/dosis). Infusión continua: 20 - 50 mcg/kg/minuto. Endotraqueal: 2 - 3 mg/kg.'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Lidocaina FA 5ml de 100mg' ,  1            ,    50  ,   false  , 'EV inf. continua'          ,      100         ,     0             , 'mg'  , 'Dosis: Arritmias Directo: 1 mg/Kg/dosis (máximo 100 mg/dosis). Infusión continua: 20 - 50 mcg/kg/minuto. Endotraqueal: 2 - 3 mg/kg.'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Lidocaina FA 5ml de 100mg' ,  1            ,    50  ,   false  , 'Intramuscular'          ,      100         ,     0             , 'mg'  , 'Dosis: Arritmias Directo: 1 mg/Kg/dosis (máximo 100 mg/dosis). Infusión continua: 20 - 50 mcg/kg/minuto. Endotraqueal: 2 - 3 mg/kg.'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Lidocaina FA 5ml de 100mg' ,  1            ,    50  ,   false  , 'Intraosea'          ,      100         ,     0             , 'mg'  , 'Dosis: Arritmias Directo: 1 mg/Kg/dosis (máximo 100 mg/dosis). Infusión continua: 20 - 50 mcg/kg/minuto. Endotraqueal: 2 - 3 mg/kg.'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Lidocaina FA 5ml de 100mg' ,  1            ,    50  ,   false  , 'Subcutánea'          ,      100         ,     0             , 'mg'  , 'Dosis: Arritmias Directo: 1 mg/Kg/dosis (máximo 100 mg/dosis). Infusión continua: 20 - 50 mcg/kg/minuto. Endotraqueal: 2 - 3 mg/kg.'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Lidocaina FA 5ml de 100mg' ,  1            ,    50  ,   false  , 'Endotraqueal'          ,      100         ,     0             , 'mg'  , 'Dosis: Arritmias Directo: 1 mg/Kg/dosis (máximo 100 mg/dosis). Infusión continua: 20 - 50 mcg/kg/minuto. Endotraqueal: 2 - 3 mg/kg.'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Linezolid 300mg de 600mg' ,  10            ,    600  ,   false  , 'EV inf. intermitente' ,      600         ,     8             , 'mg'  , 'Dosis: <12a: 10mg/kg/dosis c/8hrs   >12a:600mg c/12hrs'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Linezolid 300mg de 600mg' ,  10            ,    600  ,   false  , 'Oral' ,      600         ,     8             , 'mg'  , 'Dosis: <12a: 10mg/kg/dosis c/8hrs   >12a:600mg c/12hrs'    , 'mg/kg' ,    'mg');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Lorazepam 1ml de 4mg',  0.05            ,    2  ,   false  ,    'EV directa'          ,      4         ,     0             , 'mg'  , 'Dosis: Ansiedad - sedación: 0,05 mg/kg/dosis única o cada 4 a 8 horas. Rango: 0,02 - 0,1 mg/kg/dosis.  Status epiléptico: 0,05 - 1 mg/kg/dosis se puede repetir en 10 a 15 minutos. 0,01 - 0,1 mg/kg/hr (en infusión continua).'    , 'mg/kg' ,    'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Lorazepam 1ml de 4mg',  0.05            ,    2  ,   false  ,    'EV inf. continua'          ,      4         ,     0             , 'mg'  , 'Dosis: Ansiedad - sedación: 0,05 mg/kg/dosis única o cada 4 a 8 horas. Rango: 0,02 - 0,1 mg/kg/dosis.  Status epiléptico: 0,05 - 1 mg/kg/dosis se puede repetir en 10 a 15 minutos. 0,01 - 0,1 mg/kg/hr (en infusión continua).'    , 'mg/kg' ,    'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Lorazepam 1ml de 4mg',  0.05            ,    2  ,   false  ,    'Intramuscular'          ,      4         ,     0             , 'mg'  , 'Dosis: Ansiedad - sedación: 0,05 mg/kg/dosis única o cada 4 a 8 horas. Rango: 0,02 - 0,1 mg/kg/dosis.  Status epiléptico: 0,05 - 1 mg/kg/dosis se puede repetir en 10 a 15 minutos. 0,01 - 0,1 mg/kg/hr (en infusión continua).'    , 'mg/kg' ,    'mg/dosis');
INSERT INTO medicamento(nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad)  VALUES ('Lorazepam 1ml de 4mg',  0.05            ,    2  ,   false  ,    'Oral'          ,      4         ,     0             , 'mg'  , 'Dosis: Ansiedad - sedación: 0,05 mg/kg/dosis única o cada 4 a 8 horas. Rango: 0,02 - 0,1 mg/kg/dosis.  Status epiléptico: 0,05 - 1 mg/kg/dosis se puede repetir en 10 a 15 minutos. 0,01 - 0,1 mg/kg/hr (en infusión continua).'    , 'mg/kg' ,    'mg/dosis');

INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Meropenem 500mg', 20, 1, false, 'EV directa', 500, 8, 'mg', 'PRESENTACIÓN: P. Liofilizado 500mg. Duplicar dosis (recomendada y máxima) en caso de infección severa. Administrar infusión Continua en caso de paciente crítico.', 'mg/kg', 'gr');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Meropenem 500mg', 20, 1, false, 'EV inf. intermitente', 500, 8, 'mg', 'PRESENTACIÓN: P. Liofilizado 500mg. Duplicar dosis (recomendada y máxima) en caso de infección severa. Administrar infusión Continua en caso de paciente crítico.', 'mg/kg', 'gr');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Meropenem 500mg', 20, 1, false, 'EV inf. continua', 500, 8, 'mg', 'PRESENTACIÓN: P. Liofilizado 500mg. Duplicar dosis (recomendada y máxima) en caso de infección severa. Administrar infusión Continua en caso de paciente crítico.', 'mg/kg', 'gr');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Meropenem 1000mg', 20, 1, false, 'EV directa', 1000, 8, 'mg', 'PRESENTACIÓN: P. Liofilizado 1000mg. Duplicar dosis (recomendada y máxima) en caso de infección severa. Administrar infusión Continua en caso de paciente crítico.', 'mg/kg', 'gr');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Meropenem 1000mg', 20, 1, false, 'EV inf. intermitente', 1000, 8, 'mg', 'PRESENTACIÓN: P. Liofilizado 1000mg. Duplicar dosis (recomendada y máxima) en caso de infección severa. Administrar infusión Continua en caso de paciente crítico.', 'mg/kg', 'gr');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Meropenem 1000mg', 20, 1, false, 'EV inf. continua', 1000, 8, 'mg', 'PRESENTACIÓN: P. Liofilizado 1000mg. Duplicar dosis (recomendada y máxima) en caso de infección severa. Administrar infusión Continua en caso de paciente crítico.', 'mg/kg', 'gr');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Metamizol', 25, 40, false, 'EV inf. intermitente', 2, 8, 'ml/g', 'PRESENTACIÓN: FA 2ml/1g. Lactantes no usar vía endovenosa de administración.', 'mg/kg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Metamizol', 25, 40, false, 'EV inf. continua', 2, 8, 'ml/g', 'PRESENTACIÓN: FA 2ml/1g. Lactantes no usar vía endovenosa de administración.', 'mg/kg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Metamizol', 25, 40, false, 'Intramuscular', 2, 8, 'ml/g', 'PRESENTACIÓN: FA 2ml/1g. Lactantes no usar vía endovenosa de administración.', 'mg/kg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Metamizol', 25, 40, false, 'Rectal', 2, 8, 'ml/g', 'PRESENTACIÓN: FA 2ml/1g. Lactantes no usar vía endovenosa de administración.', 'mg/kg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Metamizol', 25, 40, false, 'Oral', 2, 8, 'ml/g', 'PRESENTACIÓN: FA 2ml/1g. Lactantes no usar vía endovenosa de administración.', 'mg/kg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Metilprednisolona 40mg de 1ml', 2, 0, false, 'EV directa', 40, 8, 'mg/ml', 'PRESENTACIÓN: P. liofilizado 40mg+1ml. Disolvente. Inmunosupresión: 5 - 10 mg/kg/día. Pulsos: 30mg/kg por una vez.', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Metilprednisolona 40mg de 1ml', 2, 0, false, 'EV inf. intermitente', 40, 8, 'mg/ml', 'PRESENTACIÓN: P. liofilizado 40mg+1ml. Disolvente. Inmunosupresión: 5 - 10 mg/kg/día. Pulsos: 30mg/kg por una vez.', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Metilprednisolona 40mg de 1ml', 2, 0, false, 'Intramuscular', 40, 8, 'mg/ml', 'PRESENTACIÓN: P. liofilizado 40mg+1ml. Disolvente. Inmunosupresión: 5 - 10 mg/kg/día. Pulsos: 30mg/kg por una vez.', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Metilprednisolona 500mg de 8ml', 2, 0, false, 'EV directa', 62.5, 8, 'mg/ml', 'Presentación:P. liofilizado 500mg+8ml. Disolvente. Inmunosupresión: 5 - 10 mg/kg/día. Pulsos: 30mg/kg por una vez.', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Metilprednisolona 500mg de 8ml', 2, 0, false, 'EV inf. intermitente', 62.5, 8, 'mg/ml', 'Presentación:P. liofilizado 500mg+8ml. Disolvente. Inmunosupresión: 5 - 10 mg/kg/día. Pulsos: 30mg/kg por una vez.', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Metilprednisolona 500mg de 8ml', 2, 0, false, 'Intramuscular', 62.5, 8, 'mg/ml', 'Presentación:P. liofilizado 500mg+8ml. Disolvente. Inmunosupresión: 5 - 10 mg/kg/día. Pulsos: 30mg/kg por una vez.', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Metoclopramida', 0.3, 5, false, 'EV directa', 0.2, 8, 'ml/mg', 'PRESENTACIÓN: 2ml/10mg. Reflujo gastroesofágico: 0,15 - 0,3 mg/kg/dosis cada 6 - 8 horas.Nauseas y vómitos perioperatorios: 0,2 - 0,3 mg/kg/dosis cada 6 - 8 horas.', 'mg/kg', 'mg/ml');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Metoclopramida', 0.3, 5, false, 'EV inf. intermitente', 0.2, 8, 'ml/mg', 'PRESENTACIÓN: 2ml/10mg. Reflujo gastroesofágico: 0,15 - 0,3 mg/kg/dosis cada 6 - 8 horas.Nauseas y vómitos perioperatorios: 0,2 - 0,3 mg/kg/dosis cada 6 - 8 horas.', 'mg/kg', 'mg/ml');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Metoclopramida', 0.3, 5, false, 'Intramuscular', 0.2, 8, 'ml/mg', 'PRESENTACIÓN: 2ml/10mg. Reflujo gastroesofágico: 0,15 - 0,3 mg/kg/dosis cada 6 - 8 horas.Nauseas y vómitos perioperatorios: 0,2 - 0,3 mg/kg/dosis cada 6 - 8 horas.', 'mg/kg', 'mg/ml');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Metoclopramida', 0.3, 5, false, 'Oral', 0.2, 8, 'ml/mg', 'PRESENTACIÓN: 2ml/10mg. Reflujo gastroesofágico: 0,15 - 0,3 mg/kg/dosis cada 6 - 8 horas.Nauseas y vómitos perioperatorios: 0,2 - 0,3 mg/kg/dosis cada 6 - 8 horas.', 'mg/kg', 'mg/ml');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Metronidazol', 7.5, 4, false, 'EV inf. intermitente', 0.2, 6, 'ml/mg', 'PRESENTACIÓN: 100ml/500mg. Dosis Recomendada: 30mg/kg/día, divididos en 4 tomas.', 'mg/kg', 'g/día');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Metronidazol', 7.5, 4, false, 'Oral', 0.2, 6, 'ml/mg', 'PRESENTACIÓN: 100ml/500mg. Dosis Recomendada: 30mg/kg/día, divididos en 4 tomas.', 'mg/kg', 'g/día');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Midazolam 5mg de 1ml', 0.1, 0, false, 'EV directa', 0.2, 1, 'ml/mg', 'PRESENTACIÓN: FA 1ml/5mg. Sedación: 0,1 - 0,2 mg/kg /dosis hasta 0,5mg/kg dosis. Recién nacido con menos de 32 semanas de edad de gestación: 0,03 mg/Kg/h. Recién nacido con más de 32 semanas de edad de gestación y niños de hasta 6 meses: 0,06 mg/Kg/h Mayores de 6 meses: 0,06 a 0,12 mg/Kg/h', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Midazolam 5mg de 1ml', 0.1, 0, false, 'EV inf. continua', 0.2, 1, 'ml/mg', 'PRESENTACIÓN: FA 1ml/5mg. Sedación: 0,1 - 0,2 mg/kg /dosis hasta 0,5mg/kg dosis. Recién nacido con menos de 32 semanas de edad de gestación: 0,03 mg/Kg/h. Recién nacido con más de 32 semanas de edad de gestación y niños de hasta 6 meses: 0,06 mg/Kg/h Mayores de 6 meses: 0,06 a 0,12 mg/Kg/h', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Midazolam 5mg de 1ml', 0.1, 0, false, 'Intramuscular', 0.2, 1, 'ml/mg', 'PRESENTACIÓN: FA 1ml/5mg. Sedación: 0,1 - 0,2 mg/kg /dosis hasta 0,5mg/kg dosis. Recién nacido con menos de 32 semanas de edad de gestación: 0,03 mg/Kg/h. Recién nacido con más de 32 semanas de edad de gestación y niños de hasta 6 meses: 0,06 mg/Kg/h Mayores de 6 meses: 0,06 a 0,12 mg/Kg/h', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Midazolam 5mg de 1ml', 0.1, 0, false, 'Oral', 0.2, 1, 'ml/mg', 'PRESENTACIÓN: FA 1ml/5mg. Sedación: 0,1 - 0,2 mg/kg /dosis hasta 0,5mg/kg dosis. Recién nacido con menos de 32 semanas de edad de gestación: 0,03 mg/Kg/h. Recién nacido con más de 32 semanas de edad de gestación y niños de hasta 6 meses: 0,06 mg/Kg/h Mayores de 6 meses: 0,06 a 0,12 mg/Kg/h', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Midazolam 5mg de 1ml', 0.1, 0, false, 'Endotraqueal', 0.2, 1, 'ml/mg', 'PRESENTACIÓN: FA 1ml/5mg. Sedación: 0,1 - 0,2 mg/kg /dosis hasta 0,5mg/kg dosis. Recién nacido con menos de 32 semanas de edad de gestación: 0,03 mg/Kg/h. Recién nacido con más de 32 semanas de edad de gestación y niños de hasta 6 meses: 0,06 mg/Kg/h Mayores de 6 meses: 0,06 a 0,12 mg/Kg/h', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Midazolam 15mg de 3ml', 0.1, 0, false, 'EV directa', 0.2, 1, 'ml/mg', 'PRESENTACIÓN: FA 3ml/15mg. Sedación: 0,1 - 0,2 mg/kg /dosis hasta 0,5mg/kg dosis. Recién nacido con menos de 32 semanas de edad de gestación: 0,03 mg/Kg/h. Recién nacido con más de 32 semanas de edad de gestación y niños de hasta 6 meses: 0,06 mg/Kg/h Mayores de 6 meses: 0,06 a 0,12 mg/Kg/h', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Midazolam 15mg de 3ml', 0.1, 0, false, 'EV inf. continua', 0.2, 1, 'ml/mg', 'PRESENTACIÓN: FA 3ml/15mg. Sedación: 0,1 - 0,2 mg/kg /dosis hasta 0,5mg/kg dosis. Recién nacido con menos de 32 semanas de edad de gestación: 0,03 mg/Kg/h. Recién nacido con más de 32 semanas de edad de gestación y niños de hasta 6 meses: 0,06 mg/Kg/h Mayores de 6 meses: 0,06 a 0,12 mg/Kg/h', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Midazolam 15mg de 3ml', 0.1, 0, false, 'Intramuscular', 0.2, 1, 'ml/mg', 'PRESENTACIÓN: FA 3ml/15mg. Sedación: 0,1 - 0,2 mg/kg /dosis hasta 0,5mg/kg dosis. Recién nacido con menos de 32 semanas de edad de gestación: 0,03 mg/Kg/h. Recién nacido con más de 32 semanas de edad de gestación y niños de hasta 6 meses: 0,06 mg/Kg/h Mayores de 6 meses: 0,06 a 0,12 mg/Kg/h', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Midazolam 15mg de 3ml', 0.1, 0, false, 'Oral', 0.2, 1, 'ml/mg', 'PRESENTACIÓN: FA 3ml/15mg. Sedación: 0,1 - 0,2 mg/kg /dosis hasta 0,5mg/kg dosis. Recién nacido con menos de 32 semanas de edad de gestación: 0,03 mg/Kg/h. Recién nacido con más de 32 semanas de edad de gestación y niños de hasta 6 meses: 0,06 mg/Kg/h Mayores de 6 meses: 0,06 a 0,12 mg/Kg/h', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Midazolam 15mg de 3ml', 0.1, 0, false, 'Endotraqueal', 0.2, 1, 'ml/mg', 'PRESENTACIÓN: FA 3ml/15mg. Sedación: 0,1 - 0,2 mg/kg /dosis hasta 0,5mg/kg dosis. Recién nacido con menos de 32 semanas de edad de gestación: 0,03 mg/Kg/h. Recién nacido con más de 32 semanas de edad de gestación y niños de hasta 6 meses: 0,06 mg/Kg/h Mayores de 6 meses: 0,06 a 0,12 mg/Kg/h', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Midazolam 50mg de 10ml', 0.1, 0, false, 'EV directa', 0.2, 1, 'ml/mg', 'PRESENTACIÓN: FA 10ml/50mg (clorhidratos). Sedación: 0,1 - 0,2 mg/kg /dosis hasta 0,5mg/kg dosis. Recién nacido con menos de 32 semanas de edad de gestación: 0,03 mg/Kg/h. Recién nacido con más de 32 semanas de edad de gestación y niños de hasta 6 meses: 0,06 mg/Kg/h Mayores de 6 meses: 0,06 a 0,12 mg/Kg/h', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Midazolam 50mg de 10ml', 0.1, 0, false, 'EV inf. continua', 0.2, 1, 'ml/mg', 'PRESENTACIÓN: FA 10ml/50mg (clorhidratos). Sedación: 0,1 - 0,2 mg/kg /dosis hasta 0,5mg/kg dosis. Recién nacido con menos de 32 semanas de edad de gestación: 0,03 mg/Kg/h. Recién nacido con más de 32 semanas de edad de gestación y niños de hasta 6 meses: 0,06 mg/Kg/h Mayores de 6 meses: 0,06 a 0,12 mg/Kg/h', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Midazolam 50mg de 10ml', 0.1, 0, false, 'Intramuscular', 0.2, 1, 'ml/mg', 'PRESENTACIÓN: FA 10ml/50mg (clorhidratos). Sedación: 0,1 - 0,2 mg/kg /dosis hasta 0,5mg/kg dosis. Recién nacido con menos de 32 semanas de edad de gestación: 0,03 mg/Kg/h. Recién nacido con más de 32 semanas de edad de gestación y niños de hasta 6 meses: 0,06 mg/Kg/h Mayores de 6 meses: 0,06 a 0,12 mg/Kg/h', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Midazolam 50mg de 10ml', 0.1, 0, false, 'Oral', 0.2, 1, 'ml/mg', 'PRESENTACIÓN: FA 10ml/50mg (clorhidratos). Sedación: 0,1 - 0,2 mg/kg /dosis hasta 0,5mg/kg dosis. Recién nacido con menos de 32 semanas de edad de gestación: 0,03 mg/Kg/h. Recién nacido con más de 32 semanas de edad de gestación y niños de hasta 6 meses: 0,06 mg/Kg/h Mayores de 6 meses: 0,06 a 0,12 mg/Kg/h', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Midazolam 50mg de 10ml', 0.1, 0, false, 'Endotraqueal', 0.2, 1, 'ml/mg', 'PRESENTACIÓN: FA 10ml/50mg (clorhidratos). Sedación: 0,1 - 0,2 mg/kg /dosis hasta 0,5mg/kg dosis. Recién nacido con menos de 32 semanas de edad de gestación: 0,03 mg/Kg/h. Recién nacido con más de 32 semanas de edad de gestación y niños de hasta 6 meses: 0,06 mg/Kg/h Mayores de 6 meses: 0,06 a 0,12 mg/Kg/h', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Milrinona', 0.1, 1000, false, 'EV inf. intermitente', 1, 1, 'ml/mg', 'PRESENTACIÓN: 10ml/10mg (lactato). Sedación: 0,1 - 0,2 mg/kg /dosis hasta 0,5mg/kg dosis. Recién nacido con menos de 32 semanas de edad de gestación: 0,03 mg/Kg/h. Recién nacido con más de 32 semanas de edad de gestación y niños de hasta 6 meses: 0,06 mg/Kg/h Mayores de 6 meses: 0,06 a 0,12 mg/Kg/h', 'mg/kg', 'mcg/ml');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Milrinona', 0.1, 1000, false, 'EV inf. continua', 1, 1, 'ml/mg', 'PRESENTACIÓN: 10ml/10mg (lactato). Sedación: 0,1 - 0,2 mg/kg /dosis hasta 0,5mg/kg dosis. Recién nacido con menos de 32 semanas de edad de gestación: 0,03 mg/Kg/h. Recién nacido con más de 32 semanas de edad de gestación y niños de hasta 6 meses: 0,06 mg/Kg/h Mayores de 6 meses: 0,06 a 0,12 mg/Kg/h', 'mg/kg', 'mcg/ml');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Morfina', 0.1, 15, false, 'EV directa', 0.1, 4, 'ml/mg', 'PRESENTACIÓN: 1ml/10mg. Bic neonatos: 10 - 30 mcg/kg/hr. Bic niños o adultos: 20 - 80 mcg/kg/hr. Como analgésico: vía Subcutánea: 0,1 - 0,2 mg /Kg cada cuatro horas.', 'mg/kg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Morfina', 0.1, 15, false, 'EV inf. continua', 0.1, 4, 'ml/mg', 'PRESENTACIÓN: 1ml/10mg. Bic neonatos: 10 - 30 mcg/kg/hr. Bic niños o adultos: 20 - 80 mcg/kg/hr. Como analgésico: vía Subcutánea: 0,1 - 0,2 mg /Kg cada cuatro horas.', 'mg/kg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Morfina', 0.1, 15, false, 'Intramuscular', 0.1, 4, 'ml/mg', 'PRESENTACIÓN: 1ml/10mg. Bic neonatos: 10 - 30 mcg/kg/hr. Bic niños o adultos: 20 - 80 mcg/kg/hr. Como analgésico: vía Subcutánea: 0,1 - 0,2 mg /Kg cada cuatro horas.', 'mg/kg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Morfina', 0.1, 15, false, 'Subcutánea', 0.1, 4, 'ml/mg', 'PRESENTACIÓN: 1ml/10mg. Bic neonatos: 10 - 30 mcg/kg/hr. Bic niños o adultos: 20 - 80 mcg/kg/hr. Como analgésico: vía Subcutánea: 0,1 - 0,2 mg /Kg cada cuatro horas.', 'mg/kg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Naloxona', 2, 0.4, false, 'EV directa', 2.5, 12, 'ml/mg', 'PRESENTACIÓN: 1ml/0.4mg. DOSIS: Contrarrestar sedación: 2 mcg/kg/dosis, repetir después de 2 minutos. Antagonismo morfina: 10 mcg/kg/dosis (Max. 0,4 mg).', 'mcg/kg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Naloxona', 2, 0.4, false, 'EV inf. continua', 2.5, 12, 'ml/mg', 'PRESENTACIÓN: 1ml/0.4mg. DOSIS: Contrarrestar sedación: 2 mcg/kg/dosis, repetir después de 2 minutos. Antagonismo morfina: 10 mcg/kg/dosis (Max. 0,4 mg).', 'mcg/kg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Naloxona', 2, 0.4, false, 'Intramuscular', 2.5, 12, 'ml/mg', 'PRESENTACIÓN: 1ml/0.4mg. DOSIS: Contrarrestar sedación: 2 mcg/kg/dosis, repetir después de 2 minutos. Antagonismo morfina: 10 mcg/kg/dosis (Max. 0,4 mg).', 'mcg/kg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Naloxona', 2, 0.4, false, 'Subcutánea', 2.5, 12, 'ml/mg', 'PRESENTACIÓN: 1ml/0.4mg. DOSIS: Contrarrestar sedación: 2 mcg/kg/dosis, repetir después de 2 minutos. Antagonismo morfina: 10 mcg/kg/dosis (Max. 0,4 mg).', 'mcg/kg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Naloxona', 2, 0.4, false, 'Intraosea', 2.5, 12, 'ml/mg', 'PRESENTACIÓN: 1ml/0.4mg. DOSIS: Contrarrestar sedación: 2 mcg/kg/dosis, repetir después de 2 minutos. Antagonismo morfina: 10 mcg/kg/dosis (Max. 0,4 mg).', 'mcg/kg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Neostigmina', 0.05, 0, false, 'EV directa', 2, 4, 'ml/mg', 'PRESENTACIÓN: 1ml/0.5mg. DOSIS: Antídoto relajantes musculares: 0,05 - 0,07 mg/kg/dosis. Tratamiento miastenia gravis: 0,01 - 0,04 mg/kg/dosis cada 2 a 4 horas.', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Neostigmina', 0.05, 0, false, 'Intramuscular', 2, 4, 'ml/mg', 'PRESENTACIÓN: 1ml/0.5mg. DOSIS: Antídoto relajantes musculares: 0,05 - 0,07 mg/kg/dosis. Tratamiento miastenia gravis: 0,01 - 0,04 mg/kg/dosis cada 2 a 4 horas.', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Neostigmina', 0.05, 0, false, 'Subcutánea', 2, 4, 'ml/mg', 'PRESENTACIÓN: 1ml/0.5mg. DOSIS: Antídoto relajantes musculares: 0,05 - 0,07 mg/kg/dosis. Tratamiento miastenia gravis: 0,01 - 0,04 mg/kg/dosis cada 2 a 4 horas.', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Neostigmina', 0.05, 0, false, 'Oral', 2, 4, 'ml/mg', 'PRESENTACIÓN: 1ml/0.5mg. DOSIS: Antídoto relajantes musculares: 0,05 - 0,07 mg/kg/dosis. Tratamiento miastenia gravis: 0,01 - 0,04 mg/kg/dosis cada 2 a 4 horas.', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Nitroglicerina', 0.5, 400, false, 'EV inf. continua', 0.2, 1, 'ml/mg', 'PRESENTACIÓN: FA 10ml/50mg.', 'mcg/kg/min', 'mcg/ml');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Nitroglicerina', 0.5, 400, false, 'Oral', 0.2, 1, 'ml/mg', 'PRESENTACIÓN: FA 10ml/50mg.', 'mcg/kg/min', 'mcg/ml');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Nitroglicerina', 0.5, 400, false, 'Transdérmico', 0.2, 1, 'ml/mg', 'PRESENTACIÓN: FA 10ml/50mg.', 'mcg/kg/min', 'mcg/ml');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Nitroprusiano', 0.5, 4, false, 'EV inf. continua', 50, 1, 'mg', 'PRESENTACIÓN: P. Liofilizado 50mg + disolvente. DOSIS: Menores de 30 kg: 3 mg/kg en 50 ml de suero glucosado al 5% a 0,5 - 4 ml/hr (0,5 – 4 mcg/kg/min). Mayores a 30 kilos: 3 mg/kg en 100 ml de suero glucosado al 5% a 1 - 8 ml/hr (0,5 – 4 mcg/kg/min)', 'mcg/kg/min', 'mcg/kg/min');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Norepinefrina', 0.1, 0, false, 'EV inf. continua', 1, 1, 'ml/mg', 'PRESENTACIÓN: FA 4ml/4mg. DOSIS: 0.1-2mcg/kg/min.', 'mcg/kg/min', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Omeprazol', 1, 80, false, 'EV directa', 4, 1, 'mg/ml', 'PRESENTACIÓN: P. liofilizado 40mg + 10ml. Solvente.', 'mg/kg/día', 'mg/día');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Omeprazol', 1, 80, false, 'Oral', 4, 1, 'mg/ml', 'PRESENTACIÓN: P. liofilizado 40mg + 10ml. Solvente.', 'mg/kg/día', 'mg/día');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ondansetron 8mg de 4ml', 0.15, 8, false, 'EV directa', 2, 1, 'mg/ml', 'PRESENTACIÓN: FA 8mg:4ml. DOSIS: Profilaxis: 0.15mg/kg, tratamiento: 0.2mg/kg.', 'mg/kg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ondansetron 8mg de 4ml', 0.15, 8, false, 'EV inf. continua', 2, 1, 'mg/ml', 'PRESENTACIÓN: FA 8mg:4ml. DOSIS: Profilaxis: 0.15mg/kg, tratamiento: 0.2mg/kg.', 'mg/kg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ondansetron 8mg de 4ml', 0.15, 8, false, 'Intramuscular', 2, 1, 'mg/ml', 'PRESENTACIÓN: FA 8mg:4ml. DOSIS: Profilaxis: 0.15mg/kg, tratamiento: 0.2mg/kg.', 'mg/kg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ondansetron 8mg de 4ml', 0.15, 8, false, 'Oral', 2, 1, 'mg/ml', 'PRESENTACIÓN: FA 8mg:4ml. DOSIS: Profilaxis: 0.15mg/kg, tratamiento: 0.2mg/kg.', 'mg/kg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ondansetron 8mg de 4ml', 0.15, 8, false, 'Rectal', 2, 1, 'mg/ml', 'PRESENTACIÓN: FA 8mg:4ml. DOSIS: Profilaxis: 0.15mg/kg, tratamiento: 0.2mg/kg.', 'mg/kg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ondansetron 4mg de 2ml', 0.15, 8, false, 'EV directa', 2, 1, 'mg/ml', 'PRESENTACIÓN: FA 8mg:4ml. DOSIS: Profilaxis: 0.15mg/kg, tratamiento: 0.2mg/kg.', 'mg/kg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ondansetron 4mg de 2ml', 0.15, 8, false, 'EV inf. continua', 2, 1, 'mg/ml', 'PRESENTACIÓN: FA 8mg:4ml. DOSIS: Profilaxis: 0.15mg/kg, tratamiento: 0.2mg/kg.', 'mg/kg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ondansetron 4mg de 2ml', 0.15, 8, false, 'Intramuscular', 2, 1, 'mg/ml', 'PRESENTACIÓN: FA 8mg:4ml. DOSIS: Profilaxis: 0.15mg/kg, tratamiento: 0.2mg/kg.', 'mg/kg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ondansetron 4mg de 2ml', 0.15, 8, false, 'Oral', 2, 1, 'mg/ml', 'PRESENTACIÓN: FA 8mg:4ml. DOSIS: Profilaxis: 0.15mg/kg, tratamiento: 0.2mg/kg.', 'mg/kg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ondansetron 4mg de 2ml', 0.15, 8, false, 'Rectal', 2, 1, 'mg/ml', 'PRESENTACIÓN: FA 8mg:4ml. DOSIS: Profilaxis: 0.15mg/kg, tratamiento: 0.2mg/kg.', 'mg/kg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Papaverina', 1.5, 0, false, 'EV directa', 40, 6, 'mg/ml', 'PRESENTACIÓN: 80mg/2ml. DOSIS: 1.5kg/kg c/6hrs.', 'mg/kg/hr', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Papaverina', 1.5, 0, false, 'EV inf. intermitente', 40, 6, 'mg/ml', 'PRESENTACIÓN: 80mg/2ml. DOSIS: 1.5kg/kg c/6hrs.', 'mg/kg/hr', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Papaverina', 1.5, 0, false, 'Intramuscular', 40, 6, 'mg/ml', 'PRESENTACIÓN: 80mg/2ml. DOSIS: 1.5kg/kg c/6hrs.', 'mg/kg/hr', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Papaverina', 1.5, 0, false, 'Oral', 40, 6, 'mg/ml', 'PRESENTACIÓN: 80mg/2ml. DOSIS: 1.5kg/kg c/6hrs.', 'mg/kg/hr', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Penicilina G Sódica', 100000, 0, false, 'EV inf. intermitente', 1000000, 1, 'UI', 'PRESENTACIÓN: P. Liofilizado 1.000.000UI (sal sódica). DOSIS: E.V., I.M.: 100.000 - 250.000 U.I./Kg/día en dosis divididas cada 4 - 6 horas. En meningitis bacteriana y otras infecciones severas: E.V., I.M.: 250.000 - 400.000 U.I./Kg/día en dosis divididas cada 4 - 6 horas.', 'UI/kg/día', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Penicilina G Sódica', 100000, 0, false, 'EV inf. continua', 1000000, 1, 'UI', 'PRESENTACIÓN: P. Liofilizado 1.000.000UI (sal sódica). DOSIS: E.V., I.M.: 100.000 - 250.000 U.I./Kg/día en dosis divididas cada 4 - 6 horas. En meningitis bacteriana y otras infecciones severas: E.V., I.M.: 250.000 - 400.000 U.I./Kg/día en dosis divididas cada 4 - 6 horas.', 'UI/kg/día', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Penicilina G Sódica', 100000, 0, false, 'Intramuscular', 1000000, 1, 'UI', 'PRESENTACIÓN: P. Liofilizado 1.000.000UI (sal sódica). DOSIS: E.V., I.M.: 100.000 - 250.000 U.I./Kg/día en dosis divididas cada 4 - 6 horas. En meningitis bacteriana y otras infecciones severas: E.V., I.M.: 250.000 - 400.000 U.I./Kg/día en dosis divididas cada 4 - 6 horas.', 'UI/kg/día', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Petidina', 0.1, 0, false, 'EV directa', 0.02, 1, 'ml/mg', 'PRESENTACIÓN: 2ml:100mg (clorhidrato). DOSIS: E.V: 0,5 - 1 mg/kg. I.M: 0,5 - 2 mg/kg. Infusion continua: 5 mg/kg en 50 ml, 1 - 4 ml/hr (0,1 - 0,4 mg/kg/hr).', 'mg/kg/hr', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Petidina', 0.1, 0, false, 'EV inf. intermitente', 0.02, 1, 'ml/mg', 'PRESENTACIÓN: 2ml:100mg (clorhidrato). DOSIS: E.V: 0,5 - 1 mg/kg. I.M: 0,5 - 2 mg/kg. Infusion continua: 5 mg/kg en 50 ml, 1 - 4 ml/hr (0,1 - 0,4 mg/kg/hr).', 'mg/kg/hr', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Petidina', 0.1, 0, false, 'EV inf. continua', 0.02, 1, 'ml/mg', 'PRESENTACIÓN: 2ml:100mg (clorhidrato). DOSIS: E.V: 0,5 - 1 mg/kg. I.M: 0,5 - 2 mg/kg. Infusion continua: 5 mg/kg en 50 ml, 1 - 4 ml/hr (0,1 - 0,4 mg/kg/hr).', 'mg/kg/hr', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Petidina', 0.1, 0, false, 'Intramuscular', 0.02, 1, 'ml/mg', 'PRESENTACIÓN: 2ml:100mg (clorhidrato). DOSIS: E.V: 0,5 - 1 mg/kg. I.M: 0,5 - 2 mg/kg. Infusion continua: 5 mg/kg en 50 ml, 1 - 4 ml/hr (0,1 - 0,4 mg/kg/hr).', 'mg/kg/hr', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Petidina', 0.1, 0, false, 'Subcutánea', 0.02, 1, 'ml/mg', 'PRESENTACIÓN: 2ml:100mg (clorhidrato). DOSIS: E.V: 0,5 - 1 mg/kg. I.M: 0,5 - 2 mg/kg. Infusion continua: 5 mg/kg en 50 ml, 1 - 4 ml/hr (0,1 - 0,4 mg/kg/hr).', 'mg/kg/hr', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Piperacilina-Tazobactam 4g', 80, 0, false, 'EV directa', 4, 1, 'g', 'PRESENTACIÓN: P. liofilizado 4g (piperacilina). DOSIS: Usual: 80 - 100 mg/Kg/día divididos en dosis cada 6 horas. En infecciones severas: 240 - 400 mg/Kg/día divididos en dosis cada 6 horas. En pacientes sobre 50 Kg usar dosis de adultos. Se calcula en base a la Piperacilina.', 'mg/Kg/día', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Piperacilina-Tazobactam 4g', 80, 0, false, 'EV inf. intermitente', 4, 1, 'g', 'PRESENTACIÓN: P. liofilizado 4g (piperacilina). DOSIS: Usual: 80 - 100 mg/Kg/día divididos en dosis cada 6 horas. En infecciones severas: 240 - 400 mg/Kg/día divididos en dosis cada 6 horas. En pacientes sobre 50 Kg usar dosis de adultos. Se calcula en base a la Piperacilina.', 'mg/Kg/día', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Piperacilina-Tazobactam 4g', 80, 0, false, 'EV inf. continua', 4, 1, 'g', 'PRESENTACIÓN: P. liofilizado 4g (piperacilina). DOSIS: Usual: 80 - 100 mg/Kg/día divididos en dosis cada 6 horas. En infecciones severas: 240 - 400 mg/Kg/día divididos en dosis cada 6 horas. En pacientes sobre 50 Kg usar dosis de adultos. Se calcula en base a la Piperacilina.', 'mg/Kg/día', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Piperacilina-Tazobactam 4g', 80, 0, false, 'Intramuscular', 4, 1, 'g', 'PRESENTACIÓN: P. liofilizado 4g (piperacilina). DOSIS: Usual: 80 - 100 mg/Kg/día divididos en dosis cada 6 horas. En infecciones severas: 240 - 400 mg/Kg/día divididos en dosis cada 6 horas. En pacientes sobre 50 Kg usar dosis de adultos. Se calcula en base a la Piperacilina.', 'mg/Kg/día', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Piperacilina-Tazobactam 0.5g', 80, 0, false, 'EV directa', 0.5, 1, 'g', 'PRESENTACIÓN: P. liofilizado 4g (piperacilina). DOSIS: Usual: 80 - 100 mg/Kg/día divididos en dosis cada 6 horas. En infecciones severas: 240 - 400 mg/Kg/día divididos en dosis cada 6 horas. En pacientes sobre 50 Kg usar dosis de adultos. Se calcula en base a la Piperacilina.', 'mg/Kg/día', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Piperacilina-Tazobactam 0.5g', 80, 0, false, 'EV inf. intermitente', 0.5, 1, 'g', 'PRESENTACIÓN: P. liofilizado 4g (piperacilina). DOSIS: Usual: 80 - 100 mg/Kg/día divididos en dosis cada 6 horas. En infecciones severas: 240 - 400 mg/Kg/día divididos en dosis cada 6 horas. En pacientes sobre 50 Kg usar dosis de adultos. Se calcula en base a la Piperacilina.', 'mg/Kg/día', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Piperacilina-Tazobactam 0.5g', 80, 0, false, 'EV inf. continua', 0.5, 1, 'g', 'PRESENTACIÓN: P. liofilizado 4g (piperacilina). DOSIS: Usual: 80 - 100 mg/Kg/día divididos en dosis cada 6 horas. En infecciones severas: 240 - 400 mg/Kg/día divididos en dosis cada 6 horas. En pacientes sobre 50 Kg usar dosis de adultos. Se calcula en base a la Piperacilina.', 'mg/Kg/día', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Piperacilina-Tazobactam 0.5g', 80, 0, false, 'Intramuscular', 0.5, 1, 'g', 'PRESENTACIÓN: P. liofilizado 4g (piperacilina). DOSIS: Usual: 80 - 100 mg/Kg/día divididos en dosis cada 6 horas. En infecciones severas: 240 - 400 mg/Kg/día divididos en dosis cada 6 horas. En pacientes sobre 50 Kg usar dosis de adultos. Se calcula en base a la Piperacilina.', 'mg/Kg/día', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Piridoxina (vit. B6)', 1.5, 0, false, 'EV directa', 0.01, 1, 'ml/mg', 'PRESENTACIÓN: Fa 1ml:100mg (clorhidrato). DOSIS: No se calcula por peso. Deficiencia de piridoxina. Inicial. 5 - 25 mg/dosis una vez al día. Mantenimiento: 1,5 - 2,5 mg/dosis una vez al día. Tratamiento de neuritis por fármacos: 10 - 50 mg/día. Status epiléptico en menores de 2 años: 100 mg/dosis.', 'mg/día', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Piridoxina (vit. B6)', 1.5, 0, false, 'Intramuscular', 0.01, 1, 'ml/mg', 'PRESENTACIÓN: Fa 1ml:100mg (clorhidrato). DOSIS: No se calcula por peso. Deficiencia de piridoxina. Inicial. 5 - 25 mg/dosis una vez al día. Mantenimiento: 1,5 - 2,5 mg/dosis una vez al día. Tratamiento de neuritis por fármacos: 10 - 50 mg/día. Status epiléptico en menores de 2 años: 100 mg/dosis.', 'mg/día', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Piridoxina (vit. B6)', 1.5, 0, false, 'Oral', 0.01, 1, 'ml/mg', 'PRESENTACIÓN: Fa 1ml:100mg (clorhidrato). DOSIS: No se calcula por peso. Deficiencia de piridoxina. Inicial. 5 - 25 mg/dosis una vez al día. Mantenimiento: 1,5 - 2,5 mg/dosis una vez al día. Tratamiento de neuritis por fármacos: 10 - 50 mg/día. Status epiléptico en menores de 2 años: 100 mg/dosis.', 'mg/día', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Potasio (cloruro) 1gr de 10ml', 0.1, 0, false, 'EV inf. intermitente', 10, 1, 'ml/g', 'PRESENTACIÓN: FA 10ml:1g (10%). DOSIS: 0,1 - 0,3 mg/kg/hr por periférica (flebo). 0,5 - 1 meq/kg/hora por CVC.', 'mg/kg/hr', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Potasio (cloruro) 1gr de 10ml', 0.1, 0, false, 'Oral', 10, 1, 'ml/g', 'PRESENTACIÓN: FA 10ml:1g (10%). DOSIS: 0,1 - 0,3 mg/kg/hr por periférica (flebo). 0,5 - 1 meq/kg/hora por CVC.', 'mg/kg/hr', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Potasio (cloruro) 1gr de 5ml', 0.1, 0, false, 'EV inf. intermitente', 5, 1, 'ml/g', 'PRESENTACIÓN: FA 10ml:1g (10%). DOSIS: 0,1 - 0,3 mg/kg/hr por periférica (flebo). 0,5 - 1 meq/kg/hora por CVC.', 'mg/kg/hr', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Potasio (cloruro) 1gr de 5ml', 0.1, 0, false, 'Oral', 5, 1, 'ml/g', 'PRESENTACIÓN: FA 10ml:1g (10%). DOSIS: 0,1 - 0,3 mg/kg/hr por periférica (flebo). 0,5 - 1 meq/kg/hora por CVC.', 'mg/kg/hr', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Propofol', 1, 0, false, 'EV directa', 0.1, 1, 'ml/mg', 'PRESENTACIÓN: 20ml:200mg (form. Lipídica). DOSIS: Sedación: 1 - 3 mg/kg/hr (max 4mg/kg/hr), no más de 48 hr. Corto periodo de anestesia: 2,5 – 3,5 mg/kg, luego 7,5 – 15 mg/ kg/hr.', 'mg/kg/hr', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Propofol', 1, 0, false, 'EV inf. continua', 0.1, 1, 'ml/mg', 'PRESENTACIÓN: 20ml:200mg (form. Lipídica). DOSIS: Sedación: 1 - 3 mg/kg/hr (max 4mg/kg/hr), no más de 48 hr. Corto periodo de anestesia: 2,5 – 3,5 mg/kg, luego 7,5 – 15 mg/ kg/hr.', 'mg/kg/hr', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Propanolol', 0.01, 1, false, 'EV inf. intermitente', 1, 1, 'ml/mg', 'PRESENTACIÓN: 1ml:1mg. DOSIS: Arritmias: 0,01 - 0,25 mg/kg/dosis.  Hipertensión: 0,01 - 0,05 mg/kg/dosis. MAX: 1mg en lactantes. 3mg en niños.', 'mg/kg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Propanolol', 0.01, 1, false, 'Oral', 1, 1, 'ml/mg', 'PRESENTACIÓN: 1ml:1mg. DOSIS: Arritmias: 0,01 - 0,25 mg/kg/dosis.  Hipertensión: 0,01 - 0,05 mg/kg/dosis. MAX: 1mg en lactantes. 3mg en niños.', 'mg/kg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Protamina', 1, 50, false, 'EV directa', 0.1, 1, 'ml/mg', 'PRESENTACIÓN: 5ml:50mg (sulfato). DOSIS: Neutralización heparina E.V.: La dosis de protamina es determinada por la dosis más reciente de heparina no fraccionada o heparina de bajo peso molecular: 1 mg de protamina neutraliza 100 unidades de heparina, 1 mg de enoxaparina y 100 unidades de dalteparina; dosis máxima: 50 mg. MAX: 50mg. V.: Debido a que las concentraciones sanguíneas de heparina decrecen rápidamente la relación de heparina: protamina va cambiando en el tiempo. Ver monogramas diseñados para este fin.', 'mg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Protamina', 1, 50, false, 'EV inf. continua', 0.1, 1, 'ml/mg', 'PRESENTACIÓN: 5ml:50mg (sulfato). DOSIS: Neutralización heparina E.V.: La dosis de protamina es determinada por la dosis más reciente de heparina no fraccionada o heparina de bajo peso molecular: 1 mg de protamina neutraliza 100 unidades de heparina, 1 mg de enoxaparina y 100 unidades de dalteparina; dosis máxima: 50 mg. MAX: 50mg. V.: Debido a que las concentraciones sanguíneas de heparina decrecen rápidamente la relación de heparina: protamina va cambiando en el tiempo. Ver monogramas diseñados para este fin.', 'mg', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ranitidina', 2, 300, false, 'EV directa', 0.04, 1, 'ml/mg', 'PRESENTACIÓN: FA 2ml:50mg (clorhidrato). DOSIS: 2-10mg/kg/día divididos en 3 dosis. MAX: 300mg/día.', 'mg/kg/día', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ranitidina', 2, 300, false, 'EV inf. intermitente', 0.04, 1, 'ml/mg', 'PRESENTACIÓN: FA 2ml:50mg (clorhidrato). DOSIS: 2-10mg/kg/día divididos en 3 dosis. MAX: 300mg/día.', 'mg/kg/día', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ranitidina', 2, 300, false, 'EV inf. continua', 0.04, 1, 'ml/mg', 'PRESENTACIÓN: FA 2ml:50mg (clorhidrato). DOSIS: 2-10mg/kg/día divididos en 3 dosis. MAX: 300mg/día.', 'mg/kg/día', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ranitidina', 2, 300, false, 'Intramuscular', 0.04, 1, 'ml/mg', 'PRESENTACIÓN: FA 2ml:50mg (clorhidrato). DOSIS: 2-10mg/kg/día divididos en 3 dosis. MAX: 300mg/día.', 'mg/kg/día', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Ranitidina', 2, 300, false, 'Oral', 0.04, 1, 'ml/mg', 'PRESENTACIÓN: FA 2ml:50mg (clorhidrato). DOSIS: 2-10mg/kg/día divididos en 3 dosis. MAX: 300mg/día.', 'mg/kg/día', 'mg');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Rocuronio', 0.6, 0, false, 'EV directa', 0.1, 1, 'ml/mg', 'PRESENTACIÓN: Vial 5ml: 50mg. DOSIS: 0,6 - 1,2 mg/kg, luego bolos de 0,1 – 0,2 mg/kg o en infusión continua de 5 - 15 mcg/kg/min.', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Rocuronio', 0.6, 0, false, 'EV inf. continua', 0.1, 1, 'ml/mg', 'PRESENTACIÓN: Vial 5ml: 50mg. DOSIS: 0,6 - 1,2 mg/kg, luego bolos de 0,1 – 0,2 mg/kg o en infusión continua de 5 - 15 mcg/kg/min.', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Rocuronio', 0.6, 0, false, 'Intramuscular', 0.1, 1, 'ml/mg', 'PRESENTACIÓN: Vial 5ml: 50mg. DOSIS: 0,6 - 1,2 mg/kg, luego bolos de 0,1 – 0,2 mg/kg o en infusión continua de 5 - 15 mcg/kg/min.', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Succinilcolina', 1, 0, false, 'EV directa', 0.05, 1, 'ml/mg', 'PRESENTACIÓN: FA 5ml:100mg (clorhidrato). DOSIS: Neonatos: 3 mg/kg. Niños: Inicial 1 - 2 mg/kg, mantenimiento 0,3 - 0,6 mg/kg cada 5 - 10 min según necesidad.', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Succinilcolina', 1, 0, false, 'Intramuscular', 0.05, 1, 'ml/mg', 'PRESENTACIÓN: FA 5ml:100mg (clorhidrato). DOSIS: Neonatos: 3 mg/kg. Niños: Inicial 1 - 2 mg/kg, mantenimiento 0,3 - 0,6 mg/kg cada 5 - 10 min según necesidad.', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Sulfato de Magnesio', 0.2, 1, false, 'EV inf. intermitente', 5, 1, 'ml', 'PRESENTACIÓN: Ampolla 5ml:25%Mg+ (correspondiente a 1250mg Mg+/amp). DOSIS: Hipomagnesemia: 0,2 – 0,4 mEq/kg/dosis (25 - 50 mg MgSO4/Kg/ dosis) cada 4 - 6 horas, por 3 - 4 dosis. Máximo 16 mEq por dosis (2000 mg MgSO4/dosis). Repetir si la hipomagnesemia continúa. Dosis de mantención: 0,25 – 0,5 mEq/kg/día (30,8 - 61,6 mg MgSO4/Kg/dosis). Tratamiento convulsiones e hipertensión: 0,16 – 0,81 mEq/kg/dosis (20 - 100 mg MgSO4/kg/dosis cada 4 - 6 horas). Tratamiento Torsades de Pointes. 0,2 – 0,4 mEq Mg/kg/dosis (20 - 50 mg MgSO4/kg/dosis cada 4 - 6 horas). Máximo 2000 mg MgSO4/dosis. Tratamiento alternativo asma severa. 0,2 - 0,6 mEq Mg/Kg/dosis (20 - 75 mg MgSO4/kg/dosis cada 4 - 6 horas) en 20 minutos. MAX: EV inf. intermitente: No exceder 1 mEq/kg/hora (125 mg/kg/hora de sulfato de magnesio o 120 mg/minuto). En situaciones especiales puede ser infundido en 15 - 20 minutos.', 'mEq/kg', 'mEq/kg/hora');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Sulfato de Magnesio', 0.2, 1, false, 'EV inf. continua', 5, 1, 'ml', 'PRESENTACIÓN: Ampolla 5ml:25%Mg+ (correspondiente a 1250mg Mg+/amp). DOSIS: Hipomagnesemia: 0,2 – 0,4 mEq/kg/dosis (25 - 50 mg MgSO4/Kg/ dosis) cada 4 - 6 horas, por 3 - 4 dosis. Máximo 16 mEq por dosis (2000 mg MgSO4/dosis). Repetir si la hipomagnesemia continúa. Dosis de mantención: 0,25 – 0,5 mEq/kg/día (30,8 - 61,6 mg MgSO4/Kg/dosis). Tratamiento convulsiones e hipertensión: 0,16 – 0,81 mEq/kg/dosis (20 - 100 mg MgSO4/kg/dosis cada 4 - 6 horas). Tratamiento Torsades de Pointes. 0,2 – 0,4 mEq Mg/kg/dosis (20 - 50 mg MgSO4/kg/dosis cada 4 - 6 horas). Máximo 2000 mg MgSO4/dosis. Tratamiento alternativo asma severa. 0,2 - 0,6 mEq Mg/Kg/dosis (20 - 75 mg MgSO4/kg/dosis cada 4 - 6 horas) en 20 minutos. MAX: EV inf. intermitente: No exceder 1 mEq/kg/hora (125 mg/kg/hora de sulfato de magnesio o 120 mg/minuto). En situaciones especiales puede ser infundido en 15 - 20 minutos.', 'mEq/kg', 'mEq/kg/hora');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Sulfato de Magnesio', 0.2, 1, false, 'Intramuscular', 5, 1, 'ml', 'PRESENTACIÓN: Ampolla 5ml:25%Mg+ (correspondiente a 1250mg Mg+/amp). DOSIS: Hipomagnesemia: 0,2 – 0,4 mEq/kg/dosis (25 - 50 mg MgSO4/Kg/ dosis) cada 4 - 6 horas, por 3 - 4 dosis. Máximo 16 mEq por dosis (2000 mg MgSO4/dosis). Repetir si la hipomagnesemia continúa. Dosis de mantención: 0,25 – 0,5 mEq/kg/día (30,8 - 61,6 mg MgSO4/Kg/dosis). Tratamiento convulsiones e hipertensión: 0,16 – 0,81 mEq/kg/dosis (20 - 100 mg MgSO4/kg/dosis cada 4 - 6 horas). Tratamiento Torsades de Pointes. 0,2 – 0,4 mEq Mg/kg/dosis (20 - 50 mg MgSO4/kg/dosis cada 4 - 6 horas). Máximo 2000 mg MgSO4/dosis. Tratamiento alternativo asma severa. 0,2 - 0,6 mEq Mg/Kg/dosis (20 - 75 mg MgSO4/kg/dosis cada 4 - 6 horas) en 20 minutos. MAX: EV inf. intermitente: No exceder 1 mEq/kg/hora (125 mg/kg/hora de sulfato de magnesio o 120 mg/minuto). En situaciones especiales puede ser infundido en 15 - 20 minutos.', 'mEq/kg', 'mEq/kg/hora');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Sulfato de Magnesio', 0.2, 1, false, 'Oral', 5, 1, 'ml', 'PRESENTACIÓN: Ampolla 5ml:25%Mg+ (correspondiente a 1250mg Mg+/amp). DOSIS: Hipomagnesemia: 0,2 – 0,4 mEq/kg/dosis (25 - 50 mg MgSO4/Kg/ dosis) cada 4 - 6 horas, por 3 - 4 dosis. Máximo 16 mEq por dosis (2000 mg MgSO4/dosis). Repetir si la hipomagnesemia continúa. Dosis de mantención: 0,25 – 0,5 mEq/kg/día (30,8 - 61,6 mg MgSO4/Kg/dosis). Tratamiento convulsiones e hipertensión: 0,16 – 0,81 mEq/kg/dosis (20 - 100 mg MgSO4/kg/dosis cada 4 - 6 horas). Tratamiento Torsades de Pointes. 0,2 – 0,4 mEq Mg/kg/dosis (20 - 50 mg MgSO4/kg/dosis cada 4 - 6 horas). Máximo 2000 mg MgSO4/dosis. Tratamiento alternativo asma severa. 0,2 - 0,6 mEq Mg/Kg/dosis (20 - 75 mg MgSO4/kg/dosis cada 4 - 6 horas) en 20 minutos. MAX: EV inf. intermitente: No exceder 1 mEq/kg/hora (125 mg/kg/hora de sulfato de magnesio o 120 mg/minuto). En situaciones especiales puede ser infundido en 15 - 20 minutos.', 'mEq/kg', 'mEq/kg/hora');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Teicoplanina 200mg', 10, 0, false, 'EV directa', 200, 12, 'mg', 'PRESENTACIÓN: P. liofilizado 200mg (con o sin 3ml. Disolvente). DOSIS: Dosis de carga: 3 dosis de 10 mg/kg cada 12 horas, luego continuar con dosis de mantención de 6 - 10 mg/kg/día en dosis una vez al día.', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Teicoplanina 200mg', 10, 0, false, 'EV inf. intermitente', 200, 12, 'mg', 'PRESENTACIÓN: P. liofilizado 200mg (con o sin 3ml. Disolvente). DOSIS: Dosis de carga: 3 dosis de 10 mg/kg cada 12 horas, luego continuar con dosis de mantención de 6 - 10 mg/kg/día en dosis una vez al día.', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Teicoplanina 200mg', 10, 0, false, 'Intramuscular', 200, 12, 'mg', 'PRESENTACIÓN: P. liofilizado 200mg (con o sin 3ml. Disolvente). DOSIS: Dosis de carga: 3 dosis de 10 mg/kg cada 12 horas, luego continuar con dosis de mantención de 6 - 10 mg/kg/día en dosis una vez al día.', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Teicoplanina 400mg', 10, 0, false, 'EV directa', 400, 12, 'mg', 'PRESENTACIÓN: P. liofilizado 200mg (con o sin 3ml. Disolvente). DOSIS: Dosis de carga: 3 dosis de 10 mg/kg cada 12 horas, luego continuar con dosis de mantención de 6 - 10 mg/kg/día en dosis una vez al día.', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Teicoplanina 400mg', 10, 0, false, 'EV inf. intermitente', 400, 12, 'mg', 'PRESENTACIÓN: P. liofilizado 200mg (con o sin 3ml. Disolvente). DOSIS: Dosis de carga: 3 dosis de 10 mg/kg cada 12 horas, luego continuar con dosis de mantención de 6 - 10 mg/kg/día en dosis una vez al día.', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Teicoplanina 400mg', 10, 0, false, 'Intramuscular', 400, 12, 'mg', 'PRESENTACIÓN: P. liofilizado 200mg (con o sin 3ml. Disolvente). DOSIS: Dosis de carga: 3 dosis de 10 mg/kg cada 12 horas, luego continuar con dosis de mantención de 6 - 10 mg/kg/día en dosis una vez al día.', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Tiopental', 2, 0, false, 'EV inf. intermitente', 500, 1, 'mg', 'PRESENTACIÓN: P. liofilizado 500mg (sal sódica). DOSIS: Inducción de anestesia. Bolo E.V.: 2 – 5 mg/kg/dosis. Infusión continua: 1 - 5 mg/kg/h.', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Tiopental', 2, 0, false, 'EV inf. continua', 500, 1, 'mg', 'PRESENTACIÓN: P. liofilizado 500mg (sal sódica). DOSIS: Inducción de anestesia. Bolo E.V.: 2 – 5 mg/kg/dosis. Infusión continua: 1 - 5 mg/kg/h.', 'mg/kg', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cotrimoxazol (Trimetropin-Sulfametoxazol) 80mg de 5ml', 3, 0, false, 'EV inf. continua', 0.0625, 1, 'ml/mg', 'PRESENTACIÓN: Amp. 5ml:80mg(trimetropin). DOSIS: El cálculo de dosis se hace en base al trimetoprim. 3mg – 6 mg /kg/día, fraccionado cada 12 horas. Tratamiento pneumocystis jiroveci: 15 - 20 mg/kg/día en dosis divididas cada 12 horas. Fiebre tifoidea: 8 - 12 mg/kg/día, fraccionado cada 6 horas. MAX: No administrar a lactantes menores de 2 meses.', 'mg /kg/día', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cotrimoxazol (Trimetropin-Sulfametoxazol) 80mg de 5ml', 3, 0, false, 'Oral', 0.0625, 1, 'ml/mg', 'PRESENTACIÓN: Amp. 5ml:80mg(trimetropin). DOSIS: El cálculo de dosis se hace en base al trimetoprim. 3mg – 6 mg /kg/día, fraccionado cada 12 horas. Tratamiento pneumocystis jiroveci: 15 - 20 mg/kg/día en dosis divididas cada 12 horas. Fiebre tifoidea: 8 - 12 mg/kg/día, fraccionado cada 6 horas. MAX: No administrar a lactantes menores de 2 meses.', 'mg /kg/día', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cotrimoxazol (Trimetropin-Sulfametoxazol) 400mg de 5ml', 3, 0, false, 'EV inf. continua', 0.0125, 1, 'ml/mg', 'PRESENTACIÓN: Amp. 5ml:80mg(trimetropin). DOSIS: El cálculo de dosis se hace en base al trimetoprim. 3mg – 6 mg /kg/día, fraccionado cada 12 horas. Tratamiento pneumocystis jiroveci: 15 - 20 mg/kg/día en dosis divididas cada 12 horas. Fiebre tifoidea: 8 - 12 mg/kg/día, fraccionado cada 6 horas. MAX: No administrar a lactantes menores de 2 meses.', 'mg /kg/día', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Cotrimoxazol (Trimetropin-Sulfametoxazol) 400mg de 5ml', 3, 0, false, 'Oral', 0.0125, 1, 'ml/mg', 'PRESENTACIÓN: Amp. 5ml:80mg(trimetropin). DOSIS: El cálculo de dosis se hace en base al trimetoprim. 3mg – 6 mg /kg/día, fraccionado cada 12 horas. Tratamiento pneumocystis jiroveci: 15 - 20 mg/kg/día en dosis divididas cada 12 horas. Fiebre tifoidea: 8 - 12 mg/kg/día, fraccionado cada 6 horas. MAX: No administrar a lactantes menores de 2 meses.', 'mg /kg/día', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Vancomicina 500mg', 40, 10, false, 'EV inf. intermitente', 500, 6, 'mg', 'PRESENTACIÓN: P. Liofilizado 500mg. DOSIS: Infecciones moderadas: 40 mg/kg/día cada 6 horas. Infecciones severas: 60 mg/kg/día cada 6 horas.', 'mg/kg/día', 'mg/ml');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Vancomicina 500mg', 40, 10, false, 'EV inf. continua', 500, 6, 'mg', 'PRESENTACIÓN: P. Liofilizado 500mg. DOSIS: Infecciones moderadas: 40 mg/kg/día cada 6 horas. Infecciones severas: 60 mg/kg/día cada 6 horas.', 'mg/kg/día', 'mg/ml');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Vancomicina 500mg', 40, 10, false, 'Oral', 500, 6, 'mg', 'PRESENTACIÓN: P. Liofilizado 500mg. DOSIS: Infecciones moderadas: 40 mg/kg/día cada 6 horas. Infecciones severas: 60 mg/kg/día cada 6 horas.', 'mg/kg/día', 'mg/ml');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Vancomicina 500mg', 40, 10, false, 'Intratecal', 500, 6, 'mg', 'PRESENTACIÓN: P. Liofilizado 500mg. DOSIS: Infecciones moderadas: 40 mg/kg/día cada 6 horas. Infecciones severas: 60 mg/kg/día cada 6 horas.', 'mg/kg/día', 'mg/ml');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Vancomicina 1000mg', 40, 10, false, 'EV inf. intermitente', 1000, 6, 'mg', 'PRESENTACIÓN: P. Liofilizado 500mg. DOSIS: Infecciones moderadas: 40 mg/kg/día cada 6 horas. Infecciones severas: 60 mg/kg/día cada 6 horas.', 'mg/kg/día', 'mg/ml');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Vancomicina 1000mg', 40, 10, false, 'EV inf. continua', 1000, 6, 'mg', 'PRESENTACIÓN: P. Liofilizado 500mg. DOSIS: Infecciones moderadas: 40 mg/kg/día cada 6 horas. Infecciones severas: 60 mg/kg/día cada 6 horas.', 'mg/kg/día', 'mg/ml');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Vancomicina 1000mg', 40, 10, false, 'Oral', 1000, 6, 'mg', 'PRESENTACIÓN: P. Liofilizado 500mg. DOSIS: Infecciones moderadas: 40 mg/kg/día cada 6 horas. Infecciones severas: 60 mg/kg/día cada 6 horas.', 'mg/kg/día', 'mg/ml');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Vancomicina 1000mg', 40, 10, false, 'Intratecal', 1000, 6, 'mg', 'PRESENTACIÓN: P. Liofilizado 500mg. DOSIS: Infecciones moderadas: 40 mg/kg/día cada 6 horas. Infecciones severas: 60 mg/kg/día cada 6 horas.', 'mg/kg/día', 'mg/ml');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Vecuronio', 0.08, 1, false, 'EV directa', 10, 1, 'mg', 'PRESENTACIÓN: P. liofilizado 10mg (bromuro). DOSIS: Bolo E.V.: 0,08 – 0,1 mg/kg/dosis (bolo). Se repite cada hora según necesidad. Infusión continua E.V.: 0,03 - 0,12 mg/kg/hora. MAX: 1mg/ml.', 'mg/kg', 'mg/ml');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Vecuronio', 0.08, 1, false, 'EV inf. continua', 10, 1, 'mg', 'PRESENTACIÓN: P. liofilizado 10mg (bromuro). DOSIS: Bolo E.V.: 0,08 – 0,1 mg/kg/dosis (bolo). Se repite cada hora según necesidad. Infusión continua E.V.: 0,03 - 0,12 mg/kg/hora. MAX: 1mg/ml.', 'mg/kg', 'mg/ml');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Voriconazol', 14, 0, false, 'EV inf. intermitente', 200, 1, 'mg', 'PRESENTACIÓN: P. liofilizado 200mg. DOSIS: 14 mg/Kg/día en infusión E.V. lenta divididos en dos dosis diaria.', 'mg/Kg/día', '');
INSERT INTO medicamento (nombre, dosisrecomendada, dosismax, solitos_n, via, comprimidos, frecuenciarecomendada, unidad, textoayuda, dosisunidad, dosismaxunidad) VALUES ('Voriconazol', 14, 0, false, 'Oral', 200, 1, 'mg', 'PRESENTACIÓN: P. liofilizado 200mg. DOSIS: 14 mg/Kg/día en infusión E.V. lenta divididos en dos dosis diaria.', 'mg/Kg/día', '');


-- MEDICAMENTOS + SUEROS
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (1, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (1, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (2, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (2, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (3, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (3, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (4, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (4, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (5, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (5, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (6, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (6, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (7, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (7, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (8, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (8, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (9, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (9, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (10, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (10, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (11, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (11, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (12, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (12, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (12, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (13, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (13, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (13, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (14, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (14, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (14, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (15, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (15, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (15, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (16, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (16, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (16, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (17, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (17, 4, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (17, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (18, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (18, 4, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (18, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (19, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (19, 4, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (19, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (20, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (20, 4, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (20, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (21, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (21, 4, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (21, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (22, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (22, 4, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (22, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (23, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (24, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (25, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (25, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (26, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (26, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (27, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (27, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (28, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (28, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (29, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (29, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (30, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (30, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (31, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (31, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (32, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (32, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (33, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (33, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (34, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (34, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (35, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (36, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (37, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (38, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (38, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (39, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (39, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (40, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (40, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (41, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (42, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (43, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (44, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (44, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (45, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (45, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (46, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (46, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (47, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (47, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (48, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (48, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (49, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (49, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (50, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (50, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (51, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (51, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (52, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (52, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (53, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (53, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (54, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (54, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (55, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (55, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (56, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (56, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (57, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (57, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (58, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (58, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (59, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (59, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (60, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (60, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (61, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (61, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (61, 3, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (61, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (61, 7, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (62, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (62, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (62, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (63, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (63, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (63, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (64, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (64, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (64, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (65, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (65, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (65, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (66, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (66, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (66, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (67, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (67, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (67, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (68, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (68, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (68, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (69, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (69, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (69, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (70, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (70, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (70, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (74, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (74, 4, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (75, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (75, 4, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (76, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (76, 4, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (77, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (77, 4, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (78, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (78, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (79, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (79, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (80, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (80, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (81, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (81, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (82, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (82, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (82, 3, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (82, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (83, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (83, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (83, 3, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (83, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (84, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (84, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (84, 3, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (84, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (85, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (85, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (85, 3, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (85, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (86, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (86, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (86, 3, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (86, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (87, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (87, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (87, 3, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (87, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (88, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (88, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (88, 3, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (88, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (89, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (89, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (89, 3, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (89, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (90, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (90, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (90, 3, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (90, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (91, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (91, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (91, 3, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (91, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (92, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (92, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (92, 3, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (92, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (93, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (93, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (93, 3, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (93, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (94, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (94, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (94, 3, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (94, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (95, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (95, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (95, 3, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (95, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (96, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (96, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (96, 3, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (96, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (97, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (97, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (97, 3, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (97, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (98, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (98, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (99, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (99, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (100, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (100, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (101, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (101, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (102, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (102, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (103, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (103, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (104, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (104, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (105, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (105, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (106, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (106, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (107, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (107, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (108, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (109, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (110, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (111, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (112, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (113, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (114, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (114, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (115, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (115, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (116, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (116, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (117, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (117, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (118, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (118, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (119, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (119, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (120, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (120, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (121, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (121, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (122, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (122, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (123, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (123, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (124, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (124, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (125, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (125, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (126, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (126, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (127, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (127, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (128, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (129, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (130, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (131, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (131, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (132, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (133, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (134, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (134, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (135, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (135, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (136, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (136, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (137, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (137, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (138, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (138, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (139, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (139, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (140, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (140, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (141, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (141, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (142, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (142, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (143, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (143, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (144, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (144, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (145, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (145, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (146, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (146, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (147, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (147, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (148, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (148, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (148, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (149, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (149, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (149, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (150, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (151, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (152, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (153, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (153, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (154, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (154, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (155, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (155, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (156, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (156, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (157, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (157, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (158, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (158, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (159, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (159, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (160, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (160, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (161, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (161, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (162, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (162, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (163, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (163, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (164, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (164, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (165, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (165, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (166, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (166, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (167, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (167, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (168, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (168, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (169, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (169, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (170, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (170, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (171, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (171, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (172, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (172, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (173, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (173, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (174, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (174, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (175, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (175, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (176, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (176, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (177, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (177, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (178, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (178, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (179, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (179, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (180, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (180, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (181, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (181, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (182, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (182, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (183, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (183, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (184, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (184, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (185, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (185, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (186, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (186, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (187, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (187, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (188, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (188, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (189, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (189, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (190, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (190, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (191, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (191, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (192, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (192, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (193, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (193, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (194, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (194, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (195, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (195, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (196, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (196, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (197, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (197, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (198, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (198, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (199, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (199, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (200, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (200, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (201, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (201, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (202, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (202, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (202, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (203, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (203, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (203, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (204, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (204, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (204, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (205, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (205, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (205, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (206, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (206, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (206, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (207, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (207, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (207, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (208, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (208, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (208, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (209, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (209, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (209, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (210, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (210, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (210, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (211, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (211, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (211, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (212, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (212, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (212, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (213, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (213, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (213, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (214, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (214, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (214, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (215, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (215, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (215, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (216, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (216, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (216, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (217, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (217, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (217, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (218, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (218, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (218, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (219, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (219, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (220, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (220, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (221, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (221, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (222, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (222, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (223, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (223, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (224, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (224, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (225, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (225, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (226, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (226, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (227, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (227, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (228, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (228, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (229, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (229, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (230, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (230, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (231, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (231, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (232, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (232, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (233, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (233, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (234, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (234, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (235, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (235, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (236, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (236, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (237, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (237, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (238, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (238, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (239, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (239, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (240, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (240, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (241, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (241, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (242, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (242, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (243, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (243, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (244, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (244, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (245, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (245, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (246, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (246, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (247, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (247, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (248, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (248, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (249, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (249, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (250, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (250, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (251, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (251, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (252, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (252, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (252, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (253, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (253, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (253, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (254, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (254, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (254, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (255, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (255, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (255, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (256, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (256, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (256, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (257, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (258, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (259, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (260, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (261, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (261, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (262, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (262, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (263, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (263, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (264, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (265, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (266, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (266, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (267, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (267, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (268, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (268, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (269, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (269, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (270, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (270, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (271, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (271, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (272, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (272, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (273, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (273, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (274, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (274, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (275, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (275, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (276, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (276, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (277, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (277, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (278, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (278, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (279, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (279, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (280, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (280, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (281, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (281, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (282, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (282, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (282, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (283, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (283, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (283, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (284, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (284, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (284, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (285, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (285, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (286, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (286, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (287, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (287, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (288, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (288, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (289, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (289, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (290, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (290, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (290, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (291, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (291, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (291, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (292, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (292, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (292, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (293, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (293, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (293, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (294, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (294, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (294, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (295, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (295, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (295, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (296, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (296, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (296, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (297, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (297, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (297, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (298, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (298, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (298, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (299, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (299, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (299, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (300, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (300, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (300, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (301, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (301, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (301, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (301, 7, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (301, 3, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (301, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (302, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (302, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (302, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (302, 7, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (302, 3, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (302, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (303, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (303, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (303, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (303, 7, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (303, 3, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (303, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (304, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (304, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (304, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (304, 7, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (304, 3, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (304, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (305, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (306, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (307, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (307, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (308, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (308, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (309, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (309, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (310, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (310, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (311, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (311, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (312, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (312, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (313, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (313, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (314, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (314, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (315, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (315, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (316, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (316, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (316, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (317, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (317, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (317, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (318, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (318, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (318, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (319, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (319, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (320, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (320, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (321, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (321, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (321, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (322, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (322, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (322, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (323, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (323, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (323, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (324, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (324, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (324, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (325, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (325, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (325, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (326, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (326, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (326, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (327, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (327, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (327, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (328, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (328, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (328, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (329, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (329, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (329, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (330, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (330, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (330, 5, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (331, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (331, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (332, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (332, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (333, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (334, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (335, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (336, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (337, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (337, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (338, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (338, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (339, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (339, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (340, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (340, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (341, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (341, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (342, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (342, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (343, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (343, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (344, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (344, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (345, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (345, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (345, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (346, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (346, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (346, 6, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (347, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (347, 2, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (348, 1, 1);
INSERT INTO medicamento_suero(codMed, codSuero, cantDefecto) VALUES (348, 2, 1);