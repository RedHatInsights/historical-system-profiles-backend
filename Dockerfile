FROM registry.access.redhat.com/ubi8/ubi-minimal

ARG TEST_IMAGE=false
# ARG TEST_IMAGE="false"
# ARG pgRepo="http://mirror.centos.org/centos/8-stream/BaseOS/x86_64/os/Packages/centos-stream-repos-8-4.el8.noarch.rpm"
# ARG pgRepoKey="http://mirror.centos.org/centos/8-stream/BaseOS/x86_64/os/Packages/centos-gpg-keys-8-4.el8.noarch.rpm"
# ARG devDeps="postgresql postgresql-devel net-tools iputils nmap"

ENV LC_ALL=C.utf8
ENV LANG=C.utf8

ENV APP_ROOT=/opt/app-root

ENV POETRY_CONFIG_DIR=/opt/app-root/.pypoetry/config
ENV POETRY_DATA_DIR=/opt/app-root/.pypoetry/data
ENV POETRY_CACHE_DIR=/opt/app-root/.pypoetry/cache

ENV UNLEASH_CACHE_DIR=/tmp/unleash_cache

# USER 0

WORKDIR ${APP_ROOT}/src

RUN microdnf update -y && \
    microdnf install --setopt=install_weak_deps=0 --setopt=tsflags=nodocs -y \
    git-core python39 python39-pip tzdata libpq-devel && \
    rpm -qa | sort > packages-before-devel-install.txt && \
    microdnf install --setopt=tsflags=nodocs -y python39-devel gcc && \
    rpm -qa | sort > packages-after-devel-install.txt
# RUN if [ "$TEST_IMAGE" = "true" ] ; then rpm -Uvh $pgRepo $pgRepoKey && sed -i 's/^\(enabled.*\)/\1\npriority=200/;' /etc/yum.repos.d/CentOS*.repo; fi
# RUN if [ "$TEST_IMAGE" = "true" ] ; then microdnf module enable postgresql:13 && microdnf install --nodocs -y $devDeps; fi
# RUN if [ "$TEST_IMAGE" = "true" ]; then chgrp -R 0 $APP_ROOT && chmod -R g=u $APP_ROOT; fi

# USER 1001

RUN pip3 install --upgrade pip setuptools wheel && \
    pip3 install --force-reinstall poetry~=1.6.0

COPY pyproject.toml poetry.lock ${APP_ROOT}/src

RUN poetry install --sync

RUN microdnf remove -y $( comm -13 packages-before-devel-install.txt packages-after-devel-install.txt ) && \
    rm packages-before-devel-install.txt packages-after-devel-install.txt && \
    microdnf clean all

COPY . ${APP_ROOT}/src

# allows unit tests to run successfully within the container if image is built in "test" environment
RUN if [ "$TEST_IMAGE" = "true" ]; then chgrp -R 0 $APP_ROOT && chmod -R g=u $APP_ROOT; fi

CMD poetry run ./run_app.sh
