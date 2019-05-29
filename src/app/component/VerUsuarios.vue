<template>
  <v-card>
    <v-card-title>
      <h1>Ver  usuarios</h1>
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
      :items="usuarios"
      :search="search"
      class="elevation-1"
    >
      <template v-slot:items="props">
        <td>{{ props.item.rut }}</td>
        <td class="text">{{ props.item.fullname }}</td>
        <td class="text">{{ props.item.estado }}</td>
        <td class="text">{{ props.item.user_type }}</td>
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
      usuarios: [],
      errorMessages: {},
      successAlert: false,
      failAlert: false,
      headers: [
        {
          text: 'Rut usuario',
          align: 'left',
          value: 'rut'
        },
        { text: 'Nombre', value: 'fullname' },
        { text: 'Estado', value: 'estado' },
        { text: 'Tipo de Usuario', value: 'user_type' },
        { text: 'Acciones', value: 'rut', sortable: false, width:"300px" }
      ],
    }),

    watch: {
      rut: function(){
        this.rut = format(this.rut)
      }
    },

    created () {
      this.getUsuarios()
    },

    methods: {
      getUsuarios(){
        this.$http.get("/pg/allUsuarios")
        .then(res=>{
          console.log(res.data)
          if(res.status == 200){
            this.usuarios = res.data.users;
            res.data.users.map(user=>{
              user.estado = user.bool_activo ? "Activo" : "Bloqueado"
              user.fullname = user.nombre + " " + user.apellido
            })
            console.log(this.usuarios)
            console.log("éxito en traer usuarios")
          }else{
            console.log("wiiii")
          }
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

      bloquearUsuario(user){
        console.log(user, "bloquear")
        this.$http.put(`/pg/bloquearUser/${user.rut}`)
        .then(res=>{
          swal("Éxito!", "Se ha bloqueado el usuario!", "success");
          this.getUsuarios();
        })
        .catch(err=>{
          swal("Error!", "No se ha podido desbloquear el usuario!", "error");
          console.log(err)
        })
      },

      desbloquearUsuario(user){
        console.log(user, "bloquear")
        this.$http.put(`/pg/desbloquearUser/${user.rut}`)
        .then(res=>{
          this.getUsuarios();
          swal("Éxito!", "Se ha desbloqueado el usuario!", "success");
        })
        .catch(err=>{
          swal("Error!", "No se ha podido desbloquear el usuario!", "error");
          console.log(err)
        })
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