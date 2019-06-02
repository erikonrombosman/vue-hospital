<template>
  <v-card>
    <v-card-title>
      <h1>Agregar Ficha Médica</h1>
    </v-card-title>
    <v-card-text>
      <v-container grid-list-md>
        <form>
          <div class="form-row">
            <h1>Datos de la ficha</h1>
          </div>
          <div class="form-group">
            <div class="form-row">
              <div class="col-md-3">
                  <v-combobox
                    v-model="selectPaciente"
                    :items="pacientes"
                    label="Rut o nombre del paciente"
                  ></v-combobox>
              </div>
              <div class="col-md-3">
                <v-text-field
                  v-model="pesoIngreso"
                  type="number"
                  :error-messages="errorMessages.pswd"
                  label="Peso de ingreso (kg)"
                ></v-text-field>
              </div>
              <div class="col-md-3">
                <v-text-field
                  v-model="pesoActual"
                  type="number"
                  :error-messages="errorMessages.pswd"
                  label="Peso actual (kg)"
                ></v-text-field>
              </div>
              <div class="col-md-3">
                <v-flex>
                  <v-menu
                    :close-on-content-click="false"
                    :nudge-right="40"
                    lazy
                    transition="scale-transition"
                    offset-y
                    full-width
                    min-width="290px"
                  >
                    <template v-slot:activator="{ on }">
                      <v-text-field
                        :value="date"
                        label="Fecha de Nacimiento*"
                        prepend-icon="event"
                        readonly
                        v-on="on"
                      ></v-text-field>
                    </template>
                    <v-date-picker v-model="date" @input="menu2 = false" locale="es-es" :first-day-of-week="1"></v-date-picker>
                  </v-menu>
                </v-flex>
              </div>
            </div>
          </div>
          <div class="form-group">
            <div class="form-row">
              <v-textarea
                v-model="diagnostico"
                label="Ingrese diagnóstico del paciente"
              ></v-textarea>
            </div>
          </div>

          <div class="form-row">
            <h1>Indicaciones</h1>
          </div>

          <div class="form-group">
            <div class="form-row">
              <div class="col-md-6">
                <v-text-field
                  v-model="reposo"
                  label="Reposo"
                ></v-text-field>
              </div>
              <div class="col-md-6">
                <v-text-field
                  v-model="regimen"
                  label="Régimen"
                ></v-text-field>
              </div>
            </div>
          </div>

          <div class="form-group">
            <div class="form-row">
              <div class="col-md-6">
                <v-text-field
                  v-model="oxigenoterapia"
                  label="Oxigenoterapia"
                ></v-text-field>
              </div>
              <div class="col-md-6">
                <v-text-field
                  v-model="cuidadosEnfermera"
                  label="Cuidados de enfermera"
                ></v-text-field>
              </div>
            </div>
          </div>


          <div class="form-row">
            <div class="col-md-12 align-right">
              <v-btn
                color="primary"
                @click="agregarFicha()"
                right
              >
              <v-icon>save</v-icon>
                Agregar Ficha
              </v-btn>
            </div>
          </div>
        </form>
      </v-container>
    </v-card-text>

  </v-card>
</template>

<script>
  import moment from 'moment'
import { parse } from 'path';
  moment.locale("es");
  const { validate, clean, format } = require('rut.js')
  export default {
    data: () => ({
      diagnostico: "",
      reposo: "",
      oxigenoterapia: "",
      cuidadosEnfermera: "",
      regimen: "",
      date: null,
      errorMessages: {},
      pesoIngreso: "",
      pesoActual: "",
      selectPaciente: "",
      selectMed: "",
      selectEnfermera: "",
      pacientes: [],
      enfermeres: [],
      medicos: [],
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
      this.getPacientes();
      this.getEnfermeres();
      this.getMeds();
    },

    computed:{
      user() {
        console.log(this.$store.state.user)
        return this.$store.state.user;
      }
    },

    methods: {
      getPacientes(){
        this.$http.get("/pg/pacientes")
        .then(res=>{
          let pacientes = []
          res.data.data.map(pac=>{
            pacientes.push(pac.rut + "  "+pac.nombres+" "+pac.apellidos)
          })
          this.pacientes = pacientes;
        })
        .catch(err=>{
          console.log(err)
        })
      },
      getEnfermeres(){
        this.$http.get("/pg/enfermeres")
        .then(res=>{
          let enfermeres = []
          res.data.enfermeres.map(pac=>{
            enfermeres.push(pac.rut + "  "+pac.nombre+" "+pac.apellido)
          })
          this.enfermeres = enfermeres;
        })
        .catch(err=>{
          console.log(err)
        })
      },
      tipoUsuario(){
        let userType = this.user.tipo_usuario

      },
      getMeds(){
        
        this.$http.get("/pg/mediques")
        .then(res=>{
          let medicos = []
          res.data.meds.map(med=>{
            medicos.push(med.rut + "  "+med.nombre+" "+med.apellido)
          })
          this.medicos = medicos;
        })
        .catch(err=>{
          console.log(err)
        })
      },
      agregarFicha(){
        this.$http.post("/pg/agregarFicha",{
          diagnostico: this.diagnostico,
          fechaingreso: this.date,
          fechaficha: new Date(),
          pesoingreso: parseInt(this.pesoIngreso),
          pesoactual: parseInt(this.pesoActual),
          rutpaciente: this.selectPaciente.split(" ")[0],
          estadopaciente: "Diagnóstico General"
        })
        .then(ficha=>{
          console.log("wiiiii")
        })
        .catch(err=>{
          console.log(err)
        })
      }
    }
  }
</script>