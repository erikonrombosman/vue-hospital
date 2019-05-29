const Sequelize = require('sequelize');
const PassportLocalSequelize = require('passport-local-sequelize');
//import config from '../config.json';
const bcrypt = require("bcryptjs")
//postgres://user:pass@example.com:5432/dbname
const dbUri = "postgres://postgres:postgres@localhost:5432/hospi_cqbo"
// Setup sequelize db connection
const db = new Sequelize(dbUri, { logging: false, dialect: "postgres" });

// Define the User model.
const User = db.define(
  'usuario',
  {
    rut: {
      type: Sequelize.STRING,
      primaryKey: true
    },
    nombre: Sequelize.STRING,
    apellido: Sequelize.STRING,
    password: Sequelize.STRING,
    bool_activo: Sequelize.BOOLEAN,
    tipo_usuario: Sequelize.INTEGER,
    //email: Sequelize.STRING
  },
  {
    freezeTableName: true,
    timestamps: false
  }
);



User.beforeCreate((user, options) => {
  //console.log(user)
	const salt = bcrypt.genSaltSync();
	user.password = bcrypt.hashSync(user.password, salt);
});
  
 
User.prototype.validPassword = function(password) {
  return bcrypt.compareSync(password, this.password);
}; 
// Atach passport to user model.

/*PassportLocalSequelize.attachToUser(User, {
  usernameField: 'rut',
  hashField: 'password_hash',
  saltField: 'password_salt'
});
User.update = (id, password, cb) => {
  User.findByUsername(id, (err, user) => {
    if (err)
      return cb(err);

    if (!user)
      return cb(new Error('El usuario no existe.'));

    user.setPassword(password, (err, user) => {
      if (err)
        return cb(err);

      user.setActivationKey((err, user) => {
        if (err)
          return cb(err);

        user['rut'] = id;

        user.save()
          .then(() => {
            cb(null, user);
          })
          .catch((err) => {
            cb(err)
          });
      });
    });
  });
};*/

module.exports = User;
