<?php
$Nombre_usuario=$_POST["Nombre_usuario"];
$Contrasena=$_POST["Contrasena"];
session_start();
error_reporting(0);// Esta línea de código hará que NO MUESTRE los errores en pantalla//


$_SESSION["Nombre_usuario"]=$Nombre_usuario;

$conn=mysqli_connect('localhost','root','','apo_autis');


$consulta="SELECT * FROM tbl_usuario where Nombre_usuario='$Nombre_usuario' and Contrasena='$Contrasena'";
$resultado=mysqli_query($conn,$consulta);


$filas=mysqli_fetch_array($resultado);


if ($filas['Cod_rol']==1) { // Iniciar sesión administrador //
     
     header("Location: principal.php");	

    } else if ($filas['Cod_rol']==2) { // Iniciar sesión colaborador //
    
     header("Location: menucolaborador.php");	
     
    }  else if($filas['Cod_rol']==0) { // Cuando el usuario o contraseña son incorrectos //
        //Aparecerá un mensaje y NO PODRÁ ACCEDER A DEMAS PANTALLAS//
        echo "<script>alert('EL USUARIO O CONTRASEÑA SON INCORRECTOS'); window.location.href='index.php';</script>";    
    }

mysqli_free_result($resultado);
mysqli_close($conn);
?>