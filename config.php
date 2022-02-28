<?php

$hostname = "localhost";
$username = "root";
$password = "";
$database = "apo_autis";

$conexion = mysqli_connect($hostname, $username, $password, $database);

if(!$conexion){
    die("conexión fallida");
}

?>
