FROM debian:9

ARG version
ARG node
ARG port

ENV DSS_VERSION=$version \
    DSS_DATADIR="/home/dataiku/dss" \
    DSS_PORT=$port \ 
    DSS_NODE=$node

# Dataiku account and data dir setup
RUN useradd dataiku \
    && mkdir -p /home/dataiku ${DSS_DATADIR} \
    && chown -Rh dataiku:dataiku /home/dataiku ${DSS_DATADIR}

RUN apt-get update \
    && apt-get install -y curl

# Download kit and install dependancies
RUN DSSKIT="dataiku-dss-$DSS_VERSION" \
    && cd /home/dataiku \
    && echo "+ Downloading kit" \
    && curl -OsS "https://cdn.downloads.dataiku.com/public/studio/$DSS_VERSION/$DSSKIT.tar.gz" \
    && echo "+ Extracting kit" \
    && tar xzf "$DSSKIT.tar.gz" \
    && rm "$DSSKIT.tar.gz" \
    && chown -Rh dataiku:dataiku "$DSSKIT" \
    && echo "+ Installing dependancies" \
    && "$DSSKIT"/scripts/install/install-deps.sh -yes -with-r


# Entry point
WORKDIR /home/dataiku
COPY run.sh /home/dataiku/
COPY License.json /home/dataiku/
RUN chmod -v 755 /home/dataiku/run.sh

USER dataiku
EXPOSE $DSS_PORT

CMD [ "/home/dataiku/run.sh" ]