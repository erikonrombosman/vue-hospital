const express = require("express");
const router = express.Router();
const db = require("../pgConnection");
const helpers = require("../lib/helpers");
const User = require('../models/user');

const authMiddleware = (req, res, next) => {
  if (!req.isAuthenticated()) {
    res.status(401).send('You are not authenticated')
  } else {
    return next()
  }
}

router.get("/medicamentos", (req, res)=>{
  db.any("SELECT * FROM medicamento")
  .then(meds=>{
    console.log(meds[0])
    res.status(200).json({meds})
  })
  .catch(err=>{
    console.log(err)
  })
})


router.post('/signUp', async (req, res) => {
  const newUser = {
    username: req.body.username,
    password: req.body.password,
    fullname: req.body.fullname,
    userType: req.body.userType,
    rut: req.body.rut
  };
  newUser.password = await helpers.encryptPassword(newUser.password);
  db.tx(t=>{
    return t.sequence((order, data)=>{
      if(order ==0){
        console.log(0)
        return t.none("INSERT INTO persona (rut, nombres, apellidos) VALUES ($1, $2, $3)", [newUser.rut, newUser.fullname, newUser.fullname])
      }
      if(order==1){
        return t.none("INSERT INTO usuario (rut, contrasenia, bloqueados_n) VALUES ($1, $2, $3)", [newUser.rut, newUser.password, false])
      }
    })
    .then(() => {
      console.log(newUser, "en signup");
      res.status(200).send(newUser)
    })
    .catch(err => { 
      console.log(err)
      res.status(500).send({ err: "Ocurrió un error" }) 
    })
  })  
})

router.post("/agregarPaciente", (req, res)=>{
  let queryData = {
    rut: req.body.rut,
    fechanac: req.body.fechaNacimiento,
    nombres: req.body.nombres,
    apellidos: req.body.apellidos,
    alergia: req.body.alergias
  }
  db.tx(t=>{
    let query = 'INSERT INTO paciente (${this~}) VALUES (${rut}, ${fechanac}, \
                 ${nombres}, ${apellidos}, ${alergia})'
    return t.none(query, queryData)
  })
  .then(data=>{
    res.status(200).json({message: "Éxito", paciente: queryData})
  })
  .catch(err=>{
    console.log(err)
    res.status(500).json({message: "Error", error: err})
  })
})

router.post("/agregarFicha", (req, res)=>{
  let qd = req.body
  let tipo = req.user.tipo_usuario
  if(tipo===2 || tipo===4){
    qd.rutmedico = String(req.user.rut);
    qd.rutenfermera = null
  }
  if(tipo===3 || tipo===5){
    qd.rutenfermera = String(req.user.rut);
    qd.rutmedico = null
  }
  qd.fechaficha = req.body.fechaficha.split("T")[0]
  db.tx(t=>{
    let query = "INSERT INTO ficha (${this~}) \
                VALUES (${diagnostico}, ${fechaingreso}, ${fechaficha},\
                ${pesoingreso}, ${pesoactual}, ${rutpaciente}, ${estadopaciente}, ${regimen}, ${reposo},\
                ${oxigeno}, ${cuidados}, ${rutmedico}, ${rutenfermera})"
    console.log(query)
    return t.none(query, qd) 
  })
  .then(ficha=>{
    res.status(200).json({msg:"Todo bien"})
  })
  .catch(err=>{
    console.log(err)
    res.status(500).json({msg:"Todo mal"})
  })
})

router.post("/agregarFicha2", (req, res)=>{
  let tipo = req.user.tipo_usuario
  let qd1 = {
    diagnostico: req.body.diagnostico,
    fechaingreso: req.body.fechaingreso,
    fechaficha: req.body.fechaficha,
    pesoingreso: req.body.pesoingreso,
    pesoactual: req.body.pesoactual,
    rutpaciente: req.body.rutpaciente,
    estadopaciente: req.body.estadopaciente,
    regimen: req.body.regimen,
    reposo: req.body.reposo,
    oxigeno: req.body.oxigeno,
    cuidados: req.body.cuidados,
  }
  let sueros = {}
  let codficha = -1
  let medicamentos = {}
  let qd2 = req.body.medicamentos
  let promises = []
  if(tipo===2 || tipo===4){
    qd1.rutmedico = String(req.user.rut);
    qd1.rutenfermera = null
  }
  if(tipo===3 || tipo===5){
    qd1.rutenfermera = String(req.user.rut);
    qd1.rutmedico = null
  }
  db.tx(t=>{
    return t.sequence((order, data)=>{
      if(order==0){
        let query = "INSERT INTO ficha (${this~}) \
                VALUES (${diagnostico}, ${fechaingreso}, ${fechaficha},\
                ${pesoingreso}, ${pesoactual}, ${rutpaciente}, ${estadopaciente}, ${regimen}, ${reposo},\
                ${oxigeno}, ${cuidados}, ${rutmedico}, ${rutenfermera}) RETURNING codficha"
        return t.one(query, qd1) 
      }
      if(order==1){
        codficha = data.codficha
        console.log(codficha, "codFicha", "uno")
        return t.any("SELECT * FROM suero")
      }
      if(order==2){
        data.map(suero=>{
          sueros[suero.nombre] = suero.codsuero
        })
        return t.any("SELECT * from medicamento")
      }
      if(order==3){
        data.map(med=>{
          medicamentos[med.nombre] = med.codmed
        })
        console.log(qd2)
        qd2.map(q=>{
          let qd3 = {
            codficha,
            codmed: medicamentos[q.med],
            dosis: parseInt(q.dosis),
            dosisunidad: q.unidad,
            frecuenciahoras: parseInt(q.frec.split()[0].split("/")[1]),
            dias:parseInt(q.dias),
            codsuero: sueros[q.suero]
          }
          query = "INSERT INTO indmedicas (${this~}) VALUES ( ${codficha}, ${codmed},\
                            ${dosis}, ${dosisunidad}, ${frecuenciahoras}, ${dias}, ${codsuero})"
          promises.push(t.none(query, qd3))
        })
        return t.batch(promises)
      }
    })
  })
  .then(success=>{
    console.log("exito")
    res.status(200).json({msg: `Se ha agregado la ficha con el número ${codficha}` , codficha: codficha})
  })
  .catch(err=>{
    console.log(err)
    res.status(500).json({msg: "Ha ocurrido un error", err})
  })
})

router.get("/pacientes", (req, res)=>{
  db.tx(t=>{
    let query = "SELECT * FROM paciente"
    return t.any(query)
  })
  .then(data=>{
    res.status(200).json({data})
  })
  .catch(err=>{
    res.status(500).json({message: "error", err})
  })
})

router.get("/login/:userTypeId", (req, res) => {
  const type = req.params.userTypeId
  console.log(type)
  const query = "SELECT sp.text, sp.link, sp.icon \
                  FROM user_permission up INNER JOIN system_page sp \
                  ON up.system_page_id = sp.id \
                  WHERE up.user_type_id = ${type} ORDER BY up.menu_order ASC";
  console.log(query, {type})
  db.any(query, {type})
    .then(rows => {
      if(rows.length==undefined){
        res.status(200).send([rows])
      }else{
        res.status(200).send(rows)
      }
    })
    .catch(err => {
      console.log(err)
      res.status(500).send({ err: "El tipo de usuario no existe" })
    })
})

router.get("/usersType", (req, res)=>{
  db.any("SELECT * from tipo_usuario ORDER BY tipo_usuario_id")
  .then(rows => {
    res.status(200).json({rows})
  })
  .catch(err => {
    console.log(err)
    res.status(500).send({ err: "El tipo de usuario no existe" })
  })
})

router.post("/agregarUsuario", (req, res)=>{
  console.log(req.body, "hola")
  User.create({
    rut: req.body.rut,
    nombre: req.body.nombre,
    apellido: req.body.apellido,
    password: req.body.password,
    bool_activo: true,
    tipo_usuario: req.body.tipo_usuario_id
  })
  .then(()=>{
    console.log("salió bien")
    res.status(200).send({msg: "Se ha creado el usuario correctamente"})
  })
  .catch(err=>{
    console.log(err)
    res.status(500).send({err: err, msg: "Error interno del servidor"})
  })
})

router.get("/allUsuarios", (req, res)=>{
  db.any("SELECT u.rut, u.nombre, u.bool_activo, tu.nombre as user_type, u.apellido \
                FROM usuario u INNER JOIN tipo_usuario tu ON u.tipo_usuario = tu.tipo_usuario_id")
  .then(users=>{
    console.log(users)
    res.status(200).json({users})
  })
  .catch(err=>{
    console.log(err)
    res.status(500).json({err, msg:"Ha ocurrido un error"})
  })
})

router.get("/medSueros", (req, res)=>{
  let query = "SELECT m.nombre as nombre_med, m.codmed, \
                      JSON_AGG(JSON_BUILD_OBJECT('nombre_suero', s.nombre, 'suero_id', s.codsuero)) as lista_sueros\
              FROM medicamento m INNER JOIN medicamento_suero ms ON m.codmed = ms.codmed\
                   INNER JOIN suero s ON s.codsuero = ms.codsuero\
              GROUP BY m.codmed\
              ORDER BY m.codmed";
  db.any(query)
  .then(meds=>{
    res.status(200).json({meds})
  })
  .catch(err=>{
    res.status(500).json({err, msg:"Ha ocurrido un error"})
  })
})

router.get("/enfermeres", (req, res)=>{
  db.any("SELECT rut, nombre, apellido \
                FROM usuario WHERE (tipo_usuario = 3 OR tipo_usuario = 5) AND bool_activo = TRUE")
  .then(enfermeres=>{
    console.log(enfermeres)
    res.status(200).json({enfermeres})
  })
  .catch(err=>{
    console.log(err)
    res.status(500).json({err, msg:"Ha ocurrido un error"})
  })
})

router.get("/mediques", (req, res)=>{
  db.any("SELECT rut, nombre, apellido \
                FROM usuario WHERE (tipo_usuario = 2 OR tipo_usuario = 4) AND bool_activo = TRUE")
  .then(meds=>{
    console.log(meds)
    res.status(200).json({meds})
  })
  .catch(err=>{
    console.log(err)
    res.status(500).json({err, msg:"Ha ocurrido un error"})
  })
})

router.get("/allFichas", (req, res)=>{
  let query = "SELECT f.codficha, f.diagnostico, f.fechaficha, f.pesoingreso, f.pesoactual,\
                      f.rutmedico, f.rutenfermera, f.rutpaciente, f.oxigeno, f.cuidados, f.regimen, f.reposo,\
                      CONCAT(m.rut, ' ', m.nombre ,' ',m.apellido) as medfullname, CONCAT(e.rut, ' ',e.nombre, ' ', e.apellido) as enfullname,\
                      CONCAT(p.rut, ' ', p.nombres, ' ', p.apellidos) as pacfullname\
              FROM ficha f LEFT JOIN usuario m ON f.rutmedico = m.rut\
                            LEFT JOIN usuario e ON f.rutenfermera = e.rut\
                            INNER JOIN paciente p ON f.rutpaciente = p.rut\
              ORDER BY f.fechaficha DESC"
  db.any(query)
  .then(fichas=>{
    res.status(200).json({fichas})
  })
  .catch(err=>{
    res.status(500).json({err, msg: "Ha ocurrido un error"})
  })
})

router.put("/bloquearUser/:rut", (req, res)=>{
  const rut = req.params.rut
  const query = 'UPDATE usuario SET bool_activo = FALSE WHERE rut = $1'
  console.log(rut, query)
  db.none(query, rut)
  .then(d=>{
    res.status(200).json({msg: "El usuario ha sido bloqueado"})
  })
  .catch(err=>{
    console.log(err)
    res.status(500).json({msg: "Ha ocurrido un error"})
  })
})

router.put("/desbloquearUser/:rut", (req, res)=>{
  const rut = req.params.rut
  db.none('UPDATE usuario SET bool_activo = TRUE WHERE rut =$1', rut)
  .then(d=>{
    res.status(200).json({msg: "El usuario ha sido desbloqueado"})
  })
  .catch(err=>{
    console.log(err)
    res.status(500).json({msg: "Ha ocurrido un error"})
  })
})




module.exports = router;