FROM docker.elastic.co/beats/filebeat:8.13.4
USER root
COPY filebeat.yml /usr/share/filebeat/filebeat.yml
RUN chmod 600 /usr/share/filebeat/filebeat.yml && chown root:root /usr/share/filebeat/filebeat.yml
ENTRYPOINT ["filebeat"]
CMD ["-e"]