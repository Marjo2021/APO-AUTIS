<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "apo_autis";
try {
    $db= new PDO( "mysql:host=localhost;dbname=apo_autis",
                  "root",
                  "", 
                  array(PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8"));           
} catch (Execption $e) {
    echo "ERROR DE CONEXION DE: ".$e->getMessage();
}

?>