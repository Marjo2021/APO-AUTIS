
<?php 
?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Registration Form</title>
	<link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://code.ionicframework.com/ionicons/2.0.1/css/ionicons.min.css">
</head>
<body>

  <div class="container">
    <div class="title">
       
    </div>
    <p> </p>
    <form action="" method="post">
      <h1>AGREGAR USUARIO</h1>

      <label for="">Ingresa Un Nombre de Usuario: </label>
      <input type="text" placeholder="Ingresa tu nombre de usuario" name="Nombre_usuario" autocomplete="off" onkeypress="return soloLetras(event);" required onblur="quitarespacios(this);"  oncopy="return false" onpaste="return false" minlength="5" maxlength="10"  onkeyup="mayus(this);" onKeyDown="sinespacio(this);" class="input-text" required />
      
      <label for="">Ingresa tu Correo Electronico: </label>
      <input type="email" placeholder="Correo Electronico" name="respuesta" required />

      <label for="">Ingresa una Contraseña: </label>
      <input type="password" placeholder="Ingresa una Contraseña" name="respuesta" required />


      <input type="submit" value="Crear Usuario" name="guardar">
      <p> </p>
      <input type="submit" value="Salir" name="" href="principal.php">
    </form>
    <form action="" method="post">
      <h1></h1>
    </form>


  <!--Scripts de validaciones-->  
 <script>
/*
    CREAMOS FUNCIONES PARA MOSTRAR ERROR EN PANTALLA Y ADEMAS VALIDAR SI LOS CAMPOS SON INGRESADOS CORECTAMENTE
*/

    //  validaciones de formulario
    //Funcion para que el nombre de usuario se escriba en mayuscula
    function mayus(e) {
        e.value = e.value.toUpperCase();
      };
    
      
        
          function soloLetras(e){
           key = e.keyCode || e.which;
           tecla = String.fromCharCode(key).toLowerCase();
           letras = " áéíóúabcdefghijklmnñopqrstuvwxyz123456789";
           especiales = ["8-37-39-46"];
    
           tecla_especial = false
            for(var i in especiales){
              if(key == especiales[i]){
                tecla_especial = true;
                break;
              }
            }
    
            if(letras.indexOf(tecla)==-1 && !tecla_especial){
              return false;
            }
          };
        
    
    
        // funcion para Elinimar Espacios
        function sinespacio(e) {
    
          var cadena =  e.value;
          var limpia = "";
          var parts = cadena.split(" ");
          var length = parts.length;
    
          for (var i = 0; i < length; i++) {
            nuevacadena = parts[i];
            subcadena = nuevacadena.trim();
    
            if(subcadena != "") {
              limpia += subcadena + " ";
            }
          }
    
          limpia = limpia.trim();
          e.value = limpia;
    
        };
    
      
        function quitarespacios(e) {
    
          var cadena =  e.value;
          cadena = cadena.trim();
    
          e.value = cadena;
    
        };
    

</script>

</body>
</html>

<?php require_once "include/parte_inferior.php"?>