ARG PYTHON_VERSION
FROM python:${PYTHON_VERSION}-slim-buster
WORKDIR /src
RUN pip install pipenv==2020.11.15
COPY ./Pipfile.lock ./
RUN pipenv sync --dev
COPY ./ ./
ENTRYPOINT ["pipenv", "run"]
