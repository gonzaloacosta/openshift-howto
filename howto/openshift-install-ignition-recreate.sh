#!/bin/bash

# Script para limpiar la instalacion cuando falla y hay que recrear los ignition files

# El script tiene que estar en el mismo directorio que los archivos
#       - install_config.yaml
#       - Directorio fake root para bootstrap/, master/ y worker/
#       - Directorio /var/www/html/ocp4/ignition como directorio destino a exportar.

# TBD mas inteligencia para poder trabajar con todas las opciones

# Subcomandos a desarrollar
#   - Instalar
#   - Preparar bastion
#   - Destroy de cluster
#   - Crear contenedor para transpiler

echo "Recrear ignition files para openshift..."
echo "...."

echo "1. Limpiamos los archivos ignition file..."
sudo rm -rf *.ign /var/www/html/.ign /var/www/html/ocp4/ignition/*.ign auth/ .openshift_install*  metadata

echo "2. Creamos los nuevos ignition file..."
openshift-install create ignition-configs
ls -ltr *.ign

echo "...."

echo "3. Creamos los nuevos ignition file modificados..."
sudo podman run --rm -ti --volume `pwd`:/srv:z localhost/filetranspiler:latest -i bootstrap.ign -f bootstrap -o bootstrap2.ign
sudo podman run --rm -ti --volume `pwd`:/srv:z localhost/filetranspiler:latest -i master.ign -f master -o master2.ign
sudo podman run --rm -ti --volume `pwd`:/srv:z localhost/filetranspiler:latest -i worker.ign -f worker -o worker2.ign

echo "...."

echo "4. Copiamos los ignition en el directorio a exportar /var/www/html/ocp4/ignition"
cp bootstrap2.ign /var/www/html/ocp4/ignition/bootstrap.ign
cp master2.ign /var/www/html/ocp4/ignition/master.ign
cp worker2.ign /var/www/html/ocp4/ignition/worker.ign
chmod 755 -R /var/www/html/ocp4/
ls -ltr /var/www/html/ocp4/ignition

echo "...."

echo "5. Testeamos que se puedan descargar por http..."
curl http://localhost:8080/ocp4/ignition/worker.ign