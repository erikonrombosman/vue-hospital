const Promise = require('bluebird');
const pgp = require('pg-promise');


//const dbUri = "postgres://nutricio_user_nutricion:NutriUcn_2018@45.7.229.117/nutricio_nutricion_ucn"
const uri = "postgres://postgres:postgres@localhost:5433/hospital"

const postgres = pgp({
  promiseLib: Promise,
});
const connection = postgres(uri);

module.exports = connection