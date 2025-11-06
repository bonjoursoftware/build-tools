ARG PYTHON_VERSION
FROM python:${PYTHON_VERSION}-slim AS pipenv
WORKDIR /src
RUN pip install pipenv==2025.0.4
COPY ./Pipfile.lock ./
RUN pipenv sync --dev
COPY ./ ./
ENTRYPOINT ["pipenv", "run"]

ARG PYTHON_VERSION
FROM python:${PYTHON_VERSION}-slim AS builder
ARG PROJECT_NAME
WORKDIR /${PROJECT_NAME}
RUN pip install --no-cache-dir pipenv==2025.0.4
COPY ./Pipfile.lock ./
RUN PIPENV_VENV_IN_PROJECT=1 pipenv sync

FROM python:${PYTHON_VERSION}-slim
ARG PROJECT_NAME
RUN useradd --create-home ${PROJECT_NAME}
WORKDIR /home/${PROJECT_NAME}
USER ${PROJECT_NAME}
COPY --from=builder /${PROJECT_NAME}/.venv/ /home/${PROJECT_NAME}/.local/
COPY ./${PROJECT_NAME} ./${PROJECT_NAME}
COPY ./${PROJECT_NAME}.py ./app.py
ENTRYPOINT ["python", "-u", "app.py"]
