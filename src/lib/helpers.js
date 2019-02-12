const helpers = {};
const bcrypt = require("bcryptjs");
helpers.encryptPassword = async password => {
  const salt = await bcrypt.genSalt(12);
  const pass = await bcrypt.hash(password, salt);
  return pass;
};

helpers.matchPass = async (password, savedPass) => {
  try {
    return await bcrypt.compare(password, savedPass);
  } catch (e) {
    console.log(e);
  }
};
module.exports = helpers;
