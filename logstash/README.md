# Setting up logstash and beats

Logstash and beats can be easily setup from the standard Helm "stable" repository:

    helm install --name logstash --values my-logstash.yml,my-logstash-filter.yml stable/logstash
    helm install --name filebeat --values my-filebeat.yml  stable/filebeat

where the specifics of your logstash input/filter/output portions of the config file are left to the user (examples are provided).
