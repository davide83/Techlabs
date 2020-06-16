#########################
# Plik's Dockerfile for Dokku with custom OVHcloud S3 compatible configuration file
##
# Ref. https://github.com/root-gg/plik/blob/master/Dockerfile
#
FROM rootgg/plik:1.3-RC1

WORKDIR /home/plik/server

COPY --chown=1000:1000 plikd.cfg /home/plik/server/

EXPOSE 80

USER plik

CMD ./plikd
