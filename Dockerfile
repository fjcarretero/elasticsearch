FROM centos

#ADD jdk-7u79-linux-x64.rpm .
RUN cd /tmp \
&& curl --digest -x ${http_proxy} --user ${REPO_USER}:${REPO_PASS} -LO http://filerepo.osappext.pink.eu-central-1.aws.openpaas.axa-cloud.com/liferay-docker/jdk-7u79-linux-x64.rpm \
&& rpm -i /tmp/jdk-7u79-linux-x64.rpm \
&& rm -f /tmp/jdk-7u79-linux-x64.rpm

RUN groupadd -g 1000 elasticsearch && useradd elasticsearch -u 1000 -g 1000 && usermod -u 1000 elasticsearch

RUN cd /opt \
	&& curl -LO -x ${https_proxy} https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.4.0.tar.gz \
	&& tar xvfz elasticsearch-1.4.0.tar.gz \
	&& rm elasticsearch-1.4.0.tar.gz 



RUN mkdir /opt/elasticsearch-1.4.0/data \
&& chmod -R 777 /opt/elasticsearch-1.4.0/data

WORKDIR /opt/elasticsearch-1.4.0

RUN set -ex && for path in data logs config config/scripts; do \
        mkdir -p "$path"; \
        chown -R elasticsearch:elasticsearch "$path"; \
    done

COPY logging.yml /opt/elasticsearch-1.4.0/config/
COPY elasticsearch.yml /opt/elasticsearch-1.4.0/config/
COPY start.sh /start.sh

RUN chown elasticsearch:elasticsearch /start.sh \
&& chmod +x /start.sh

RUN chown -R elasticsearch:elasticsearch /opt/elasticsearch-1.4.0 \
&& chmod -R +w /opt/elasticsearch-1.4.0

USER elasticsearch

EXPOSE 9200 9300

#ENTRYPOINT ["/opt/elasticsearch-1.4.0/bin/elasticsearch"]
ENTRYPOINT ["/start.sh"]
