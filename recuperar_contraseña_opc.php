<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Opciones Recuperar Cuenta</title>
	<link rel="stylesheet" href="css/styles.css">
</head>
<body>

  <div class="container">
    <div class="title">
       
    </div>
    <p> </p>
    <form action="" method="post">
      <h1>RECUPERAR CUENTA</h1>
      
        <label for="">Nombre de usuario: </label>
        <input type="text" placeholder="Ingrese su nombre de usuario" name="Nombre_usuario" autocomplete="off" onkeypress="return soloLetras(event);" required onblur="quitarespacios(this);"  oncopy="return false" onpaste="return false" minlength="5" maxlength="10"  onkeyup="mayus(this);" onKeyDown="sinespacio(this);" class="input-text" required />
        
        <p> ¿Cómo desea recuperar su cuenta? </p>

        <input type="submit" value="VÍA PREGUNTA SECRETA" name="pregunta_secreta" onclick= "location.href='preguntas.php'">
        <p> </p>
        <input type="submit" value="VÍA CORREO ELECTRÓNICO" name="correo_electronico" onclick= "location.href='recuperar_correo.php'">
        <p> </p>
        <center>
        <i class="fa-solid fa-arrow-left href"></i><a class="link" onclick= "location.href='login.php'">Cancelar</a>
       </center>       
    </form>


  <!--Scripts de validaciones-->  
 <script>
/*
    CREAMOS FUNCIONES PARA MOSTRAR ERROR EN PANTALLA Y ADEMAS VALIDAR SI LOS CAMPOS SON INGRESADOS CORECTAMENTE
*/

    //  validaciones de formulario
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
    
      
        function mostrarpassword (){
          var cambio = document.getElementById("ingPassword");
          if(cambio.type == "password"){
            cambio.type = "text";
            $('.icon').removeClass('fa fa-eye-slash').addClass('fa fa-eye');
          }else{
            cambio.type = "password";
            $('.icon').removeClass('fa fa-eye').addClass('fa fa-eye-slash');
          }        
        };
</script>



</body>
</html>