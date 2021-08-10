ARG PYTHON_VERSION
FROM python:${PYTHON_VERSION}-slim-buster as poetry
WORKDIR /src
RUN pip install poetry==1.1.7
COPY ./pyproject.toml ./poetry.lock ./
RUN poetry install
COPY ./ ./
ENTRYPOINT ["poetry", "run"]

ARG PYTHON_VERSION
FROM python:${PYTHON_VERSION}-slim-buster as builder
ARG PROJECT_NAME
WORKDIR /${PROJECT_NAME}
RUN pip install --no-cache-dir poetry==1.1.7
COPY ./pyproject.toml ./poetry.lock ./
RUN poetry config virtualenvs.in-project true --local \
    && poetry install --no-dev \
    && poetry cache clear pypi --all --no-interaction

FROM python:${PYTHON_VERSION}-slim-buster
ARG PROJECT_NAME
RUN useradd --create-home ${PROJECT_NAME}
WORKDIR /home/${PROJECT_NAME}
USER ${PROJECT_NAME}
COPY --from=builder /${PROJECT_NAME}/.venv/ /home/${PROJECT_NAME}/.local/
COPY ./${PROJECT_NAME} ./${PROJECT_NAME}
COPY ./${PROJECT_NAME}.py ./app.py
ENTRYPOINT ["python", "-u", "app.py"]
