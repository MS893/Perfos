@echo off
echo ==================================================
echo   COMPILATION ET DEPLOIEMENT PERFOS WEB
echo ==================================================

echo 1. Compilation Flutter Web...
call flutter build web --base-href="/Perfos/"

echo 2. Preparation des fichiers...
cd build\web

echo 3. Initialisation Git et configuration...
call git init
call git remote add origin https://github.com/MS893/Perfos.git
call git checkout -b gh-pages

echo 4. Envoi vers GitHub Pages...
call git add .
call git commit -m "Mise a jour automatique Perfos Web"
call git push origin gh-pages --force

echo ==================================================
echo   DEPLOIEMENT TERMINE AVEC SUCCES !
echo ==================================================
cd ..\..
pause