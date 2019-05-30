<template>
  <v-card>
    <v-card-title>
      <h1>Ver y agregar medicamentos</h1>
    </v-card-title>
    <v-card-text>
    <v-toolbar flat color="white">
      <v-text-field
          v-model="search"
          append-icon="search"
          label="Buscar"
          single-line
          hide-details
        ></v-text-field>
      <v-spacer></v-spacer>


      <v-dialog v-model="dialog" max-width="1200px">
        <template v-slot:activator="{ on }">
          <v-btn color="primary" dark class="mb-2" v-on="on">Agregar paciente</v-btn>
        </template>
        <v-card>
          <v-card-title>
            <span class="headline">Registrar nuevo paciente</span>
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
                        :error-messages="errorMessages.apellidos"
                        label="Rut*"
                        placeholder="12.345.678-9"
                      ></v-text-field>
                    </div>
                    <div class="col-md-6">
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
                              :value="computedDateFormattedMomentjs"
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
                  <div>
                    <label class="form-check-label" for="alergiasCheck">Marque si el paciente presenta alergias</label>
                  </div>
                  <v-textarea
                    name="input-7-1"
                    label="Alergias (opcional)"
                    value="Ingrese Alergias si es que las ubiera"
                    v-model = "alergias"
                    hint="Hint text"
                  ></v-textarea>
                </div>
                <div class="form-row">
                  <div class="col-md-12 align-right">
                    <v-btn
                      color="primary"
                      @click="agregarPaciente()"
                      right
                    >
                    <v-icon>save</v-icon>
                      Agregar Paciente
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
          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn color="blue darken-1" flat @click="close">Cancelar</v-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>


    </v-toolbar>
    <v-data-table
      :headers="headers"
      :items="medicamentos"
      :search="search"
      class="elevation-1"
      :rows-per-page-items="perPage"
      rows-per-page-text="Medacamentos por página"
    >
      <template v-slot:items="props">
        <td>{{ props.item.nombre }}</td>
        <td class="text">{{ props.item.textoayuda }}</td>
        <td class="text">{{ props.item.dosis_max }}</td>
        <td class="text">{{ props.item.receta }}</td>
        <td class="text">{{ props.item.via }}</td>
        <td class="justify-center">
          <v-icon
            small
            class="mr-2"
            @click="editItem(props.item)"
          >
            edit
          </v-icon>
          <v-icon
            small
            @click="deleteItem(props.item)"
          >
            delete
          </v-icon>
        </td>
      </template>
    </v-data-table>
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
      search: "",
      medicamentos: [],
      errorMessages: {},
      rut: null,
      nombres:null,
      apellidos: null,
      date: null,
      alergias: "camarón",
      successAlert: false,
      failAlert: false,
      perPage : [10, 25],
      headers: [
        {
          text: 'Nombre medicamento',
          align: 'left',
          value: 'nombre'
        },
        { text: 'Texto Ayuda', value: 'textoayuda' },
        { text: 'Dosis máxima', value: 'dosis_max' },
        { text: 'Receta aparte', value: 'receta', width:"20px" },
        { text: 'Vía', value: 'via' },
        { text: 'Acciones', value: 'codmed', sortable: false }
      ],
    }),

    computed: {
      formTitle () {
        return this.editedIndex === -1 ? 'New Item' : 'Edit Item'
      },
      computedDateFormattedMomentjs () {
        return this.date ? moment(this.date).format('dddd, MMMM Do YYYY') : ''
      }
    },

    watch: {
      dialog (val) {
        val || this.close()
      },
      rut: function(){
        this.rut = format(this.rut)
      }
    },

    created () {
      this.getMedicamentos()
    },

    methods: {
      getMedicamentos(){
        this.$http.get("/pg/medicamentos")
        .then(res=>{
          console.log(res.data.meds)
          if(res.status == 200){
            res.data.meds.map(med=>{
              med.receta = med.solitos_n ? "Sí" : "No"
              med.dosis_max = med.dosismax + " " + med.dosismaxunidad + "/kg" 
            });
            this.medicamentos = res.data.meds
            console.log(this.medicamentos[0])
            console.log("éxito")
          }else{
            console.log("wiiii")
          }
        })
        .catch(err=>{
          console.log(err)
        })
      },
      agregarPaciente(){
        this.$http.post("/pg/agregarPaciente",{
          rut: this.rut,
          nombres: this.nombres,
          apellidos: this.apellidos,
          fechaNacimiento: this.date,
          alergias: this.alergias
        })
        .then(res=>{
          console.log(res.data.paciente)
          this.pacientes.push(res.data.paciente);
          this.successAlert = true;
          this.failAlert = false;
          console.log("exito")
        })
        .catch(err=>{
          this.failAlert = true;
          this.successAlert = false;
          console.log("err")
        })
      },

      editItem (item) {
        //this.editedIndex = this.desserts.indexOf(item)
        this.editedItem = Object.assign({}, item)
        this.dialog = true
      },

      deleteItem (item) {
        //const index = this.desserts.indexOf(item)
        confirm('Are you sure you want to delete this item?') && this.desserts.splice(index, 1)
      },

      close () {
        this.dialog = false
        setTimeout(() => {
          this.editedItem = Object.assign({}, this.defaultItem)
          this.editedIndex = -1
        }, 300)
      }
    }
  }
</script>