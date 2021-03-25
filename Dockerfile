# Pull base R container
FROM rocker/shiny-verse:4.0.2


# Copy shiny app to container
COPY *.R /home/app/
COPY code /home/app/code
COPY data /home/app/data
COPY www /home/app/www
COPY DESCRIPTION /home/app/


# Install R packages
RUN R -e "source('/home/app/dependencies.R')"

# Required for the Workspace integrations
EXPOSE 8080

# Set up entrypoint
COPY docker/mini-app /usr/bin/mini-app
RUN chmod 755 /usr/bin/mini-app

# Run
ENTRYPOINT /usr/bin/mini-app

