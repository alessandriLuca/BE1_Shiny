# Example shiny app docker file
# https://blog.sellorm.com/2021/04/25/shiny-app-in-docker/

# get shiny serveR and a version of R from the rocker project
FROM rocker/shiny:4.0.5

# system libraries
# Try to only install system libraries you actually need
# Package Manager is a good resource to help discover system deps
RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev \
    libssl-dev
  

# install R packages required 
# Change the packages list to suit your needs
RUN R -e 'install.packages(c(\
              "shiny", \
              "shinydashboard", \
              "ggplot2" \
            ), \
            repos="https://packagemanager.rstudio.com/cran/__linux__/focal/2021-04-23"\
          )'

RUN Rscript -e 'install.packages("MatrixExtra", repos="https://cran.r-project.org")'
RUN Rscript -e 'install.packages("R.utils", repos="https://cran.r-project.org")'
RUN Rscript -e 'install.packages("shinyjs", repos="https://cran.r-project.org")'
RUN Rscript -e 'install.packages("shinyalert", repos="https://cran.r-project.org")'
RUN Rscript -e 'install.packages("shinymanager", repos="https://cran.r-project.org")'
RUN Rscript -e 'install.packages("shinycssloaders", repos="https://cran.r-project.org")'
RUN Rscript -e 'install.packages("shinymaterial", repos="https://cran.r-project.org")'
RUN Rscript -e 'install.packages("shinybusy", repos="https://cran.r-project.org")'
RUN Rscript -e 'install.packages("shinycssloaders", repos="https://cran.r-project.org")'
RUN Rscript -e 'install.packages("shinysky", repos="https://cran.r-project.org")'
RUN Rscript -e 'install.packages("shinyWidgets", repos="https://cran.r-project.org")'
RUN Rscript -e 'install.packages("shinyBS", repos="https://cran.r-project.org")'


# copy the app directory into the image
COPY ./shiny-app/* /srv/shiny-server/
COPY ./shiny-app/www /srv/shiny-server/www
RUN mkdir /srv/shiny-server/users
RUN chmod -R 777 /srv/shiny-server/users
# run app
CMD ["/usr/bin/shiny-server"]
