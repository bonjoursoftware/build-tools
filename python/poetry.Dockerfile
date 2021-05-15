ARG PYTHON_VERSION
FROM python:${PYTHON_VERSION}-slim-buster
WORKDIR /src
RUN pip install poetry==1.1.6
COPY ./pyproject.toml ./poetry.lock ./
RUN poetry install
COPY ./ ./
ENTRYPOINT ["poetry", "run"]
