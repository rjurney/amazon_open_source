FROM continuumio/anaconda

COPY . /amazon_open_source
WORKDIR /amazon_open_source

# Install Python dependencies and setup Jupyter without authentication
RUN pip install -r requirements.in && \
    jupyter notebook --generate-config && \
    echo "c.NotebookApp.token = ''" >> ~/.jupyter/jupyter_notebook_config.py

# Run Jupyter
CMD jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 --allow-root --NotebookApp.token=''
