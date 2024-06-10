FROM        node:18
RUN         useradd roboshop 
WORKDIR     /home/roboshop  
# You need to run the npm intall to have the npm modules available here.
COPY        node_modules/  node_modules/
COPY        server.js . 
COPY        package.json .
COPY        global-bundle.pem /home/roboshop/global-bundle.pem
ENTRYPOINT  ["node" , "server.js"]

# Cart talks to Catalogue and Redis, ensure you supply both of them using ConfigMap
