FROM python:3.13-slim
ENV DEBIAN_FRONTEND="noninteractive"

LABEL org.opencontainers.image.title="Base image for FollowTheMoney File Ingestors"
LABEL org.opencontainers.image.licenses="AGPL3"
LABEL org.opencontainers.image.source="https://github.com/openaleph/ingest-file-base"

# Enable non-free archive for `unrar`.
RUN echo "deb http://http.us.debian.org/debian bookworm non-free" >/etc/apt/sources.list.d/nonfree.list
RUN apt-get -qq -y update \
    && apt-get -qq -y install build-essential locales ca-certificates \
    # python deps (mostly to install their dependencies)
    python3-pip python3-dev python3-pil \
    # tesseract
    tesseract-ocr libtesseract-dev libleptonica-dev pkg-config\
    # libraries
    libxslt1-dev libpq-dev libldap2-dev libsasl2-dev \
    zlib1g-dev libicu-dev libxml2-dev \
    # package tools
    unrar p7zip-full \
    # audio & video metadata
    libmediainfo-dev \
    # image processing, djvu
    imagemagick-common imagemagick mdbtools djvulibre-bin \
    libtiff5-dev libjpeg-dev libfreetype6-dev libwebp-dev \
    libtiff-tools ghostscript librsvg2-bin jbig2dec \
    pst-utils libgif-dev \
    # necessary for python-magic
    libmagic1 \
    ### tesseract
    tesseract-ocr-eng \
    tesseract-ocr-swa \
    tesseract-ocr-swe \
    # tesseract-ocr-tam \
    # tesseract-ocr-tel \
    tesseract-ocr-fil \
    # tesseract-ocr-tha \
    tesseract-ocr-tur \
    tesseract-ocr-ukr \
    # tesseract-ocr-vie \
    tesseract-ocr-nld \
    tesseract-ocr-nor \
    tesseract-ocr-pol \
    tesseract-ocr-por \
    tesseract-ocr-ron \
    tesseract-ocr-rus \
    tesseract-ocr-slk \
    tesseract-ocr-slv \
    tesseract-ocr-spa \
    # tesseract-ocr-spa_old \
    tesseract-ocr-sqi \
    tesseract-ocr-srp \
    tesseract-ocr-ind \
    tesseract-ocr-isl \
    tesseract-ocr-ita \
    # tesseract-ocr-ita_old \
    # tesseract-ocr-jpn \
    tesseract-ocr-kan \
    tesseract-ocr-kat \
    # tesseract-ocr-kor \
    tesseract-ocr-khm  \
    tesseract-ocr-lav \
    tesseract-ocr-lit \
    # tesseract-ocr-mal \
    tesseract-ocr-mkd \
    tesseract-ocr-mya \
    tesseract-ocr-mlt \
    tesseract-ocr-msa \
    tesseract-ocr-est \
    # tesseract-ocr-eus \
    tesseract-ocr-fin \
    tesseract-ocr-fra \
    tesseract-ocr-frk \
    # tesseract-ocr-frm \
    # tesseract-ocr-glg \
    # tesseract-ocr-grc \
    tesseract-ocr-heb \
    tesseract-ocr-hin \
    tesseract-ocr-hrv \
    tesseract-ocr-hye \
    tesseract-ocr-hun \
    # tesseract-ocr-ben \
    tesseract-ocr-bul \
    tesseract-ocr-cat \
    tesseract-ocr-ces \
    tesseract-ocr-nep \
    # tesseract-ocr-chi_sim \
    # tesseract-ocr-chi_tra \
    # tesseract-ocr-chr \
    tesseract-ocr-dan \
    tesseract-ocr-deu \
    tesseract-ocr-ell \
    # tesseract-ocr-enm \
    # tesseract-ocr-epo \
    # tesseract-ocr-equ \
    tesseract-ocr-afr \
    tesseract-ocr-ara \
    tesseract-ocr-aze \
    tesseract-ocr-bel \
    tesseract-ocr-uzb \
    ### pdf convert: libreoffice + a bunch of fonts
    libreoffice fonts-opensymbol hyphen-fr hyphen-de \
    hyphen-en-us hyphen-it hyphen-ru fonts-dejavu fonts-dejavu-core fonts-dejavu-extra \
    fonts-droid-fallback fonts-dustin fonts-f500 fonts-fanwood fonts-freefont-ttf \
    fonts-liberation fonts-lmodern fonts-lyx fonts-sil-gentium fonts-texgyre \
    fonts-tlwg-purisa \
    ###
    && apt-get -qq -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# Set up the locale and make sure the system uses unicode for the file system.
ENV LANG='en_US.UTF-8' \
    TZ='UTC' \
    OMP_THREAD_LIMIT='1' \
    OPENBLAS_NUM_THREADS='1'

# tesseract 5
ENV TESSDATA_PREFIX=/usr/share/tesseract-ocr/5/tessdata

RUN groupadd -g 1000 -r app \
    && useradd -m -u 1000 -s /bin/false -g app app

# Download the ftm-typepredict model
RUN mkdir /models/ && \
    curl -o "/models/model_type_prediction.ftz" "https://public.data.occrp.org/develop/models/types/type-08012020-7a69d1b.ftz"

RUN pip3 install --no-cache-dir --prefer-binary --upgrade pip
RUN pip3 install --no-cache-dir --prefer-binary --upgrade setuptools wheel

# Install spaCy
RUN pip3 install --no-cache-dir spacy
# Install PyICU
RUN pip3 install --no-binary=:pyicu: pyicu
# Install TesserOCR
RUN pip3 install --no-binary=:tesserocr: tesserocr

# Install default (small) spaCy models
RUN python3 -m spacy download en_core_web_sm
RUN python3 -m spacy download de_core_news_sm
RUN python3 -m spacy download fr_core_news_sm
RUN python3 -m spacy download es_core_news_sm
RUN python3 -m spacy download ru_core_news_sm
RUN python3 -m spacy download pt_core_news_sm
RUN python3 -m spacy download ro_core_news_sm
RUN python3 -m spacy download mk_core_news_sm
RUN python3 -m spacy download el_core_news_sm
RUN python3 -m spacy download pl_core_news_sm
RUN python3 -m spacy download it_core_news_sm
RUN python3 -m spacy download lt_core_news_sm
RUN python3 -m spacy download nl_core_news_sm
RUN python3 -m spacy download nb_core_news_sm
RUN python3 -m spacy download da_core_news_sm
