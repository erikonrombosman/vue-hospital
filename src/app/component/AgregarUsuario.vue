<template>
  <v-card>
    <v-card-title>
      <h1>Agregar Usuarios</h1>
    </v-card-title>
    <v-card-text>
      <v-container grid-list-md>
        <form>
          <div class="form-group">
            <div class="form-row">
              <div class="col-md-6">
                <v-text-field
                  v-model="nombres"
                  type="text"
                  :error-messages="errorMessages.nombres"
                  label="Nombres*"
                  placeholder="Ingrese nombres paciente"
                ></v-text-field>
              </div>
              <div class="col-md-6">
              <v-text-field
                  v-model="apellidos"
                  type="text"
                  :error-messages="errorMessages.apellidos"
                  label="Apellidos*"
                  placeholder="Ingrese apellidos paciente"
                ></v-text-field>
              </div>
            </div>
          </div>
          <div class="form-group">
            <div class="form-row">
              <div class="col-md-6">
                <v-text-field
                  v-model="rut"
                  type="text"
                  :error-messages="errorMessages.rut"
                  label="Rut*"
                  placeholder="12.345.678-9"
                ></v-text-field>
              </div>
              <div class="col-md-6">
                <v-combobox
                  v-model="select"
                  :items="tiposUs"
                  label="Seleccione un tipo de usuario"
                ></v-combobox>
              </div>
            </div>
          </div>

          <div class="form-group">
            <div class="form-row">
              <div class="col-md-6">
                <v-text-field
                  v-model="pswd"
                  type="password"
                  :error-messages="errorMessages.pswd"
                  label="Password"
                  placeholder="********"
                ></v-text-field>
              </div>
              <div class="col-md-6">
                <v-text-field
                  v-model="repeatPassword"
                  type="password"
                  :error-messages="errorMessages.repeatPassword"
                  label="Repeat Password"
                  placeholder="********"
                ></v-text-field>
              </div>
            </div>
          </div>

          <div class="form-row">
            <div class="col-md-12 align-right">
              <v-btn
                color="primary"
                @click="agregarUsuario()"
                right
              >
              <v-icon>save</v-icon>
                Agregar Usuario
              </v-btn>
            </div>
          </div>
        </form>
        <v-alert
          :value="true"
          color="success"
          icon="check_circle"
          dismissible
          v-if="successAlert"
          @click="successAlert = false"
        >
        Se agregó el paciente correctamente.
        </v-alert>
        <v-alert
          :value="true"
          color="error"
          icon="warning"
          dismissible
          v-if="failAlert"
          @click="failAlert = false"
        >
        Ocurrió un error al agregar al paciente.
        </v-alert>
      </v-container>
    </v-card-text>

  </v-card>
</template>

<script>
  import moment from 'moment'
  moment.locale("es");
  const { validate, clean, format } = require('rut.js')
  export default {
    data: () => ({
      dialog: false,
      errorMessages: {},
      rut: null,
      nombres:null,
      apellidos: null,
      successAlert: false,
      failAlert: false,
      tiposUs: [],
      select: "enfermera-admin",
      realSelected: 0,
      pswd: "",
      repeatPassword: ""
    }),

    watch: {
      dialog (val) {
        val || this.close()
      },
      rut: function(){
        this.rut = format(this.rut)
      },
      select: function(){
        this.realSelected = this.tiposUs.indexOf(this.select) + 1;
        console.log(this.realSelected )
      }
    },

    created () {
      this.getTiposUsuario()
    },

    methods: {
      getTiposUsuario(){
        this.$http.get("/pg/usersType")
        .then(res=>{
          let tipos = []
          let ids = []
          res.data.rows.map(tipo=>{
            tipos.push(tipo.nombre)
            ids.push(tipo.tipo_usuario_id)
          })
          this.tiposUs = tipos;
          console.log(tipos, ids)
        })
        .catch(err=>{
          console.log(err)
        })
      },
      agregarUsuario(){
        this.$http.post("/pg/agregarUsuario",{
          rut: this.rut,
          nombre: this.nombres,
          apellido: this.apellidos,
          password: this.pswd,
          tipo_usuario_id: parseInt(this.realSelected)
        })
        .then(res=>{
          this.successAlert = true;
          this.failAlert = false;
          console.log(res.data)
          console.log("exito")
        })
        .catch(err=>{
          this.failAlert = true;
          this.successAlert = false;
          console.log("err")
        })
      },
    }
  }
</script>