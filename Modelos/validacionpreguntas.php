<?php
  session_start();
 include_once "conexion.php";
?> 
<?php
if(isset($_SESSION['Nombre_usuario'])) {
    $Nombre_usuario = $_SESSION['Nombre_usuario'];
     try{ 
        //$consultar_usuario="SELECT CODIGO_USUARIO FROM tbl_usuario WHERE NOMBRE_USUARIO='$usuario'";
         $sentencia = $db->prepare("SELECT Cod_usuario FROM tbl_usuario WHERE Nombre_usuario = (?);");
         $sentencia->execute(array($Nombre_usuario));
         $row=$sentencia->fetchColumn();

        //$filas=$existe->num_rows;
        if($row>0){
            $user = $row;
           if(isset($_POST['Pregunta'])){
                $pregunta=($_POST['Pregunta']);
                $respuesta=($_POST['Respuesta']);

                $consultar="SELECT * FROM tbl_pregunta_usuario r WHERE  r.Cod_usuario ='$user' AND r.Cod_pregunta = '$pregunta' AND r.Respuesta = '$respuesta';";
                $existe1=$conn->query($consultar);
                $row=$existe1->num_rows;
               if($row>0){ //Si se en la consulta hay una fila si hay registro de la busqueda ,es decir que si es correcta la respuesta
                  echo "<script>
                  alert('Respuesta correcta');
                 
                  window.location='../Vistas/modulos/cambio_contrasena_preguntas.php';
                  </script>";
                }else{ //Si no hay registros en la fila ,la respuesta es incorrecta
                  echo "<script>
                  alert('Respuesta incorrecta');
                  location.href = '../Vistas/modulos/metodos_recuperar_clave.php';
                  </script>";
                }
            }
        }else{
            echo "<script>
            alert('El Usuario Ingresado no Existe');
            window.location = '../Vistas/modulos/metodos_recuperar_clave.php';
            </script>";
        }
    }catch(PDOException $e){
    echo $e->getMessage();  
    return false; } 
}