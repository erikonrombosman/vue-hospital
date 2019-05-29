<template>
  <div class="container p-4">
    <div class="row">
      <div class="col-md-4 mx-auto">
        <div class="car text-center">
          <div class="card-header">
            <h3>SignIn</h3>
          </div>
          <div class="card-body">
            <img
              src="/rombos.jpg"
              alt="Rombosman"
              class="card-img-top mx-auto m-2 rounded-circle w-50"
            >

            <div class="form-group">
              <!--<input type="text" v-model="username" placeholder="Username" class="form-control">-->
            </div>
            <div class="form-group">
              <v-text-field
                v-model="rut"
                :error-messages="errorMessages.rut"
                label="Full Name"
                placeholder="John Doe"
              ></v-text-field>
              <v-text-field
                v-model="password"
                type="password"
                :error-messages="errorMessages.password"
                label="Password"
                placeholder="*****"
              ></v-text-field>
            </div>
            <div class="form-group">
              <v-btn color="info" @click="login()">Ingresar</v-btn>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
const { validate, clean, format } = require('rut.js')
export default {
  data() {
    return {
      rut: "",
      password: "",
      errorMessages: {}
    };
  },
  methods: {
    login() {
      this.$http
        .post("/auth/login", {
          username: this.rut,
          password: this.password
        })
        .then(res => {
          localStorage.setItem("user", JSON.stringify(res.data.user));
          this.$store.commit("changeUser", res.data.user);
          const userType = res.data.user.tipo_usuario;
          this.$http
            .get(`pg/login/${userType}`)
            .then(success => {
              console.log(success.body, "entrando al menu 1");
              localStorage.setItem("menu", JSON.stringify(success.body));
              this.$store.commit(
                "addMenu",
                JSON.parse(localStorage.getItem("menu"))
              );
              this.$router.push(`/profile`);
            })
            .catch(err => {
              console.log(err);
            });
        })
        .catch(err => {
          console.log("errorazo");
          this.errorMessages.password = "Usuario o contraseña incorrecta";
          this.password = "";
          //this.$router.push("/login");
        });
    }
  },
  watch:{
    rut: function(){
      this.rut = format(this.rut)
    }
  }
};
</script>
