const Express = require('express');
const User = require('../models/user');
const router = new Express.Router();

const passport = require('passport')
  , LocalStrategy = require('passport-local').Strategy;

passport.use(new LocalStrategy(
  function(username, password, done) {
    User.findOne({ where: {rut: username} })
    .then(user=>{
      if (!user) {
        console.log("no hay usuario")
        return done(null, false, { message: 'Incorrect username.' });
      }
      if (!user.validPassword(password)) {
        console.log("contraseña mala")
        return done(null, false, { message: 'Incorrect password.' });
      }
      done(null, user)
    })
    .catch(err=>{
      console.log(err)
      if (err) { return done(err); }
    })
  }
));
router.post('/login',passport.authenticate('local'), function(req, res){
  if(req.user){
    console.log(req.user, "user login")
    if(req.user.bool_activo){
      res.status(200).send({user: req.user})
    }else{
      res.staus(500).json({msg:"El usuario se encuentra bloqueado"})
    }
  }else{
    res.staus(500).json({msg:"Usuario o contraseña incorrectos"})
  }
});

router.post("/signUp", (req, res)=>{
  console.log(req.body, "hola")
  User.create({
    rut: req.body.rut,
    nombre: req.body.username,
    password: req.body.password,
    bool_activo: true,
    tipo_usuario_id: req.body.tipo_usuario_id
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

router.get('/checkLogin', (req, res) => {
  console.log(req.user)
  res.status(200).json({
    logged: true
  });
});

router.get("/authData", (req, res)=>{
  res.status(200).json({
    user: req.user
  })
})

router.get('/logout', (req, res) => {
  console.log("Se llama")
  req.logOut();
  res.end()
  //res.redirect(client.login);
});
/*
router.get('/update', (req, res) => {
  User.update(
    '19.207.278-6','test',
    (err, user) => {
      if(err) {
        return res.status(400).json({
          success: false,
          message: 'Error al actualizar la contraseña.',
          error: err
        })
      } else {
        return res.status(200).json({
          success: true,
          message: 'La contraseña fue actualizada'
        })
      }
    }
  );
})*/

router.get('/register', (req, res) => {
  console.log("llega acá")
  User.create(
    {rut: '19.396.079-0', user_type_id: 'ADMIN-MED', nombres: 'Erik', apellidos :'Astorga',bool_activo:true, password:'test'},
    'test')
    .then(res=>{
      console.log(res)
    })
    .catch(err=>{console.log(err)})
});

module.exports = router;