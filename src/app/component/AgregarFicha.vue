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
            <h1>Medicamentos</h1>
          </div>

          <div v-for="(med, i) in selectMedicamento" :key="i">
            <div class="form-group form-row">
              <div class="col-md-4">
                <v-combobox
                  v-model="selectMedicamento[i].med"
                  :items="medsMostrar"
                  label="Nombre del medicamento"
                ></v-combobox>
              </div>
              <div class=col-md-1>
                <v-text-field
                  type="number"
                  v-model="selectMedicamento[i].dosis"
                  label="Dosis"
                ></v-text-field>
              </div>
              <div class=col-md-1>
                <v-select
                  v-model="selectMedicamento[i].unidad"
                  :items="unidad"
                  label="Unidad"
                ></v-select>
              </div>
              <div class=col-md-2>
                <v-select
                  v-model="selectMedicamento[i].frec"
                  :items="frecuencia"
                  label="Frecuencia"
                ></v-select>
              </div>
              <div class=col-md-1>
                <v-text-field
                  type="number"
                  v-model="selectMedicamento[i].dias"
                  label="Días"
                ></v-text-field>
              </div>
              <div class="col-md-3">
                <v-combobox
                  v-model="selectMedicamento[i].suero"
                  :items="medSueros[selectMedicamento[i].med]"
                  label="Nombre del suero"
                ></v-combobox>
              </div>
            </div>
          </div>
            <v-btn
              color="primary"
              @click="agregarMedicamento()"
              right
            >
            <v-icon>save</v-icon>
              Agregar Medicamento
            </v-btn>
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
      pacientes: [],
      frecuencia: ["c/8 hrs", "c/6 hrs", "c/12 hrs", "c/24 hrs", "c/3 hrs", "c/4 hrs" ],
      unidad: ["mg", "mg/kg", "mg/día", "mg/kg/día"],
      dosis: 0,
      dias: 1,
      medSueros: {},
      selectMedicamento: [{med: "", dosis: "", unidad: "", frec: "", dias: "", suero: "", suero_id: ""}],
      medsMostrar: []
    }),


    created () {
      this.getPacientes();
      this.getMedicamentosSueros();
    },


    methods: {
      getPacientes(){
        this.$http.get("/pg/pacientes")
        .then(res=>{
          if(res.status===200){
            let pacientes = []
            res.data.data.map(pac=>{
              pacientes.push(pac.rut + "  "+pac.nombres+" "+pac.apellidos)
            })
            this.pacientes = pacientes;
          }else{
            console.log("Ha ocurrido un error");
          }
        })
        .catch(err=>{
          console.log(err)
        })
      },
      agregarMedicamento(){
        this.selectMedicamento.push({med: "", dosis: "", unidad: "", frec: "", dias: "", suero: "", suero_id: ""})
      },
      getMedicamentosSueros(){
        this.$http.get("/pg/medSueros")
        .then(res=>{
          if(res.status ===200){
            let medsMostrar = []
            let medSueros = {}
            res.data.meds.map(med=>{
              medsMostrar.push(med.nombre_med)
              let lista_sueros = []
              med.lista_sueros.map(suero=>{
                console.log(suero)
                lista_sueros.push(suero.nombre_suero)
              })
              medSueros[med.nombre_med] = lista_sueros
            })
            this.medSueros = medSueros;
            this.medsMostrar = medsMostrar;
            console.log(medSueros, medsMostrar)
          }else{

          }
        })
        .catch(err=>{

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
          estadopaciente: "Diagnóstico General",
          regimen: this.regimen,
          reposo: this.reposo,
          oxigeno: this.oxigenoterapia,
          cuidados: this.cuidadosEnfermera
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