const passport = require("passport");
const LocalStrategy = require("passport-local").Strategy;
const pool = require("../database");
const db = require("../pgConnection");
const helpers = require("../lib/helpers");

/*passport.use('local.signin', new LocalStrategy({
  usernameField: 'username',
  passwordField: 'password',
  passReqToCallback: true
}, async (req, username, password, done) => {
  //console.log(req.body, 'en la biblio')
  const row = await pool.query('SELECT * FROM users WHERE username = ? LIMIT 1', [username])
  if (row.length > 0) {
    const user = row[0];
    const validPassword = await helpers.matchPass(password, user.password);
    if (validPassword) {
      done(null, user);
    } else {
      done(null, false)
    }
  } else {
    return done(null, false)
  }
}
));*/

passport.use('local.signin', new LocalStrategy({
  usernameField: 'rut',
  passwordField: 'password',
  passReqToCallback: true
}, async (rut, password, done) => {
  db.one('SELECT * FROM usuario WHERE rut = $1', [rut])
  .then(async row=>{
    const user = row;
    const validPassword = await helpers.matchPass(password, user.contrasenia);
    console.log(password, rut, validPassword)
    console.log(user.contrasenia)
    if (validPassword) {
      console.log("válido")
      done(user)
    } else {
      console.log("malo 1")
      done(null, false)
    }
    })
    .catch(err=>{console.log(err)})
  })
);

passport.use(
  "local.signup",
  new LocalStrategy(
    {
      usernameField: "username",
      passwordField: "password",
      passReqToCallback: true
    },
    async (req, username, password, done) => {
      const { fullname } = req.body;
      const newUser = {
        username,
        password,
        fullname
      };
      newUser.password = await helpers.encryptPassword(password);
      const result = await pool.query("INSERT INTO users SET ?", [newUser]);
      newUser.id = result.insertId;
      console.log(newUser);
      return done(null, newUser);
    }
  )
);

passport.serializeUser((user, done) => {
  done(null, user.id);
});

passport.deserializeUser(async (id, done) => {
  const rows = await pool.query("SELECT * FROM users WHERE id =?", [id]);
  done(null, rows[0]);
});
