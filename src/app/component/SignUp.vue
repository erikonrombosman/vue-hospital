<template>
  <div class="container p-4">
    <div class="row">
      <div class="col-md-4 mx-auto">
        <div class="car text-center">
          <div class="card-header">
            <h3>SignUp</h3>
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
                placeholder= "XX.XXX.XXX-X"
              ></v-text-field>
              <v-text-field
                v-model="fullname"
                :error-messages="errorMessages.fullname"
                label="Full Name"
                placeholder="John Doe"
              ></v-text-field>
              <v-text-field
                v-model="password"
                type="password"
                :error-messages="errorMessages.password"
                label="Password"
                placeholder
              ></v-text-field>
              <v-text-field
                v-model="confirmPassword"
                type="password"
                :error-messages="errorMessages.confirmPassword"
                label="Confirm Password"
                placeholder
              ></v-text-field>
              <v-combobox v-model="tipo" :items="types" label="Tipo de usuario"></v-combobox>
            </div>
            <div class="form-group">
              <v-btn color="info" @click="signup()">Ingresar</v-btn>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios";
const { validate, clean, format } = require('rut.js')
//import this.$router from "../index.js";
export default {
  data() {
    return {
      username: "",
      fullname: "",
      password: "",
      confirmPassword: "",
      errorMessages: {},
      types: ["normal", "admin"],
      tipo: "",
      rut: ""
    };
  },
  methods: {
    signup() {
      if (this.password === this.confirmPassword) {
        this.$http
          .post("/auth/signUp", {
            username: this.fullname,
            password: this.password,
            confirmPassword: this.confirmPassword,
            tipo_usuario_id: this.tipo,
            rut: this.rut
          })
          .then(res => {
            console.log(res);
            this.$router.push("/login");
          })
          .catch(err => {
            console.log(err);
          });
      } else {
        this.errorMessages.password = "Las contraseñas no coinciden";
        this.errorMessages.confirmPassword = "Las contraseñas no coinciden";
        this.password = "";
        this.confirmPassword = "";
      }
    }
  },
  watch:{
    rut: function(){
      this.rut = format(this.rut)
    }
  }
};
</script>
