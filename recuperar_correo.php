
<?php
?>
<!--Pantalla para recuperar contraseña vía correo electrónico-->
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Registration Form</title>
	<link rel="stylesheet" href="css/styles.css">
</head>
<body>

  <div class="container">
    <div class="title">
       
    </div>
    <p> </p>
    <form action="" method="post">
      <h1>RECUPERAR CONTRASEÑA VÍA CORREO</h1>

      <label for="">Ingrese Su Usuario: </label>
        <input type="text" placeholder="Ingresa tu nombre de usuario" name="Nombre_usuario" autocomplete="off" onkeypress="return soloLetras(event);" required onblur="quitarespacios(this);"  oncopy="return false" onpaste="return false" minlength="5" maxlength="10"  onkeyup="mayus(this);" onKeyDown="sinespacio(this);" class="input-text" required />
      
      <!--Inicio opción Recuperar contraseña vía correo -->
  <center>
  <input type="submit" value="Enviar contraseña" name="guardar" Style="Background: green">
</center>
    <!--fin Recuperar contraseña vía correo  -->  

    <!--Inicio opción cancelar -->
    <div  style="margin-top:10px" Style="Background: green">
   
   <input type="submit" value="Cancelar" name="cancelar" onclick="location.href='login.php'">
   
</div>
</div>
    <!--fin opción cancelar -->
     </div>
      </div>
    </form>
  </center>
   <!--ver vericarpre.php -->
  <script type="text/javascript">