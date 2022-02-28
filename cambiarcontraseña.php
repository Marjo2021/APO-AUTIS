<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Registration Form</title>
	<link rel="stylesheet" href="cambiarcontraseña/styles.css">
</head>
<body>

  <div class="container">
    <div class="title">
      CAMBIAR CONTRASEÑA 
    </div>
    <div class="form">
        <div class="input-field">
          <label>Ingrese su Usuario</label>
          <input type="text" placeholder="Ingresa tu nombre de usuario" name=" " class="input" autocomplete="off" onkeypress="return soloLetras(event);" required onblur="quitarespacios(this);"  oncopy="return false" onpaste="return false" minlength="5" maxlength="15"  onkeyup="mayus(this);" onKeyDown="sinespacio(this);" required/>
        </div>  
        <div class="input-field">
          <p> </p>
          <label>Contraseña Actual</label>
          <input type="password" placeholder="Ingresa tu Contraseña Actual" name=""  class="input" required onblur="quitarespacios(this);"  onkeyup="sinespacio(this);"  minlength="8" maxlength="30" required/>
        </div>  
        <div class="input-field">
          <p> </p>
          <label>Nueva Contraseña</label>
          <input type="password" placeholder="Ingresa tu Contraseña Nueva" name=""  class="input" required onblur="quitarespacios(this);"  onkeyup="sinespacio(this);"  minlength="8" maxlength="30" required/>
        </div>  
       <div class="input-field">
         <p> </p>
          <label>Confirmar Contraseña</label>
          <input type="password" placeholder="Confirma tu Contraseña" name=""  class="input" required onblur="quitarespacios(this);"  onkeyup="sinespacio(this);"  minlength="8" maxlength="30" required/>
          
        </div> 
          
         
       <div class="input-field">
         <p> </p>
         <p> </p>
        <input type="submit" value="CAMBIAR CONTRASEÑA" name="signin" class="btn">
       </div>
    </div>
 </div>	
	
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