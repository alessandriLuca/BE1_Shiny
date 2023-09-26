docker build -t my-shiny-app .
current_directory=$(pwd)

if [ ! -d "${current_directory}/Data" ]; then
mkdir ./Data/
wget https://figshare.com/ndownloader/files/42312711 -O ./Data/zip
unzip -o ./Data/zip -d ./Data
mv ./Data/BE1run12/* ./Data/
rm -r ./Data/__MACOSX/
rm -r ./Data/BE1run12/
rm ./Data/zip
fi

docker run --rm -p 3838:3838 -v "${current_directory}/Data:/scratch" --name shiny my-shiny-app

