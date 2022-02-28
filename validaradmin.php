<?php
$Nombre_usuario=$_POST["Nombre_usuario"];
$Contrasena=$_POST["Contrasena"];
session_start();
error_reporting(0);// Esta línea de código hará que NO MUESTRE los errores en pantalla//


$_SESSION["Nombre_usuario"]=$Nombre_usuario;

$conn=mysqli_connect('localhost','root','','apo_autis');

//CREAMOS LA CONSULTA PARA LLAMAR AL PROCEDIMIENTO AL ALMACENADO LE ENVIAMOS COMO PARAMETRO EL NOMBRE DEL USUARIO EL CUAL QUEREMOS DESENCRIPTAR LA CONTRASEÑA
$consulta="CALL Sp_evaluar_contrasena_actual('$Nombre_usuario')";
// NOS CONECTAMOS A LA BD Y ENVIAMOS LA CONSULTA AL MYSQL
$resultado=mysqli_query($conn,$consulta);
//cAPTURAMOS EN LA VARIABLE LAS FILAS DE LA CONSULTA
$filas=mysqli_fetch_array($resultado);

//VERIFICAMOS EL NOMBRE, CONTRASEÑA Y ROL PARA QUE EL USUARIO INICIE SESIÓN
if ($filas['Nombre_usuario']==$Nombre_usuario && $filas['Contrasena']==$Contrasena) {
    
    if ($filas['Cod_rol']==1  ) { // Iniciar sesión administrador //
     
        header("Location: principal.php");	
   
       } else if ($filas['Cod_rol']==2) { // Iniciar sesión colaborador //
       
        header("Location: menucolaborador.php");	
        
       } elseif($filas['Cod_rol']==3); // Iniciar sesión invitado //
       header("Location: principal.php");
       {
        
        echo "<script>alert('EL USUARIO ROL ASIGNADO'); window.location.href='index.php';</script>";
       }

}else{
    echo "<script>alert('EL USUARIO O CONTRASEÑA SON INCORRECTOS'); window.location.href='index.php';</script>";
}





mysqli_free_result($resultado);
mysqli_close($conn);
?>