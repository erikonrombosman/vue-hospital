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
  let queryData = req.body
  console.log(queryData)
  res.end()
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
  const query = `SELECT sp.text, sp.link, sp.icon \
                  FROM user_permission up INNER JOIN system_page sp \
                  ON up.system_page_id = sp.id \
                  WHERE up.user_type_id = ${type} ORDER BY up.menu_order ASC`
  db.any(query)
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