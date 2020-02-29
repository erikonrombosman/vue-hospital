<template>
  <v-card>
    <v-card-title>
      <h1>Ver  Fichas</h1>
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

    </v-toolbar>
    <v-data-table
      :headers="headers"
      :items="fichas"
      :search="search"
      class="elevation-1"
    >
      <template v-slot:items="props">
        <td>{{ props.item.pacfullname }}</td>
        <td class="text">{{ props.item.mostrar }}</td>
        <td class="text">{{ props.item.fechaficha }}</td>
        <td class="text">{{ props.item.diagnostico }}</td>
        <td class="justify-center">
          <v-btn dark small color="red"
             v-if="props.item.bool_activo" 
             @click="bloquearUsuario(props.item)">
            <v-icon>highlight_off</v-icon> 
          </v-btn>
          <v-btn dark small color="green" v-if="!props.item.bool_activo"  @click="desbloquearUsuario(props.item)">
            <v-icon>done_outline</v-icon>
          </v-btn>
          <!--<v-btn dark small color="blue"   @click="desbloquearUsuario(props.item)">
            <v-icon>done_outline</v-icon>
          </v-btn>-->
        </td>
      </template>
    </v-data-table>
    </v-card-text>

  </v-card>
</template>

<script>
  import moment from 'moment'
  import swal from 'sweetalert';
  moment.locale("es");
  const { validate, clean, format } = require('rut.js')
  export default {
    data: () => ({ 
      search: "",
      fichas: [],
      errorMessages: {},
      successAlert: false,
      failAlert: false,
      headers: [
        {
          text: 'Rut paciente',
          align: 'left',
          value: 'pacfullname'
        },
        { text: 'Med/Enfermera', value: 'mostrar' },
        { text: 'Fecha', value: 'fechaficha' },
        { text: 'Diagnóstico', value: 'diagnostico' },
        { text: 'Acciones', value: 'rut', sortable: false, width:"300px" }
      ],
    }),

    watch: {
      rut: function(){
        this.rut = format(this.rut)
      }
    },

    created () {
      this.getFichas();
    },

    methods: {
      getFichas(){
        this.$http.get("/pg/allFichas")
        .then(res=>{
          let fichas = []
          res.data.fichas.map(ficha=>{
            if(ficha.rutenfermera==null){
              ficha.mostrar = ficha.medfullname
            }else{
              ficha.mostrar = ficha.enfullname
            }
            fichas.push(ficha)
          })
          this.fichas = fichas
        })
        .catch(err=>{
          console.log(err)
        })
      },

      editItem (item) {
        //this.editedIndex = this.desserts.indexOf(item)
        this.editedItem = Object.assign({}, item)
        this.dialog = true
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