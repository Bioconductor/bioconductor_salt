#!py

def run():

    import subprocess

    config = {}
    
    def find_python_path():
        p = subprocess.run(["which", "python3"], capture_output=True)
        return (p.stdout.decode("UTF-8").strip("\n"))

    python_path = find_python_path()

    config['export_RETICULATE_PYTHON'] = {
        'file.append': [
            {'name': '/etc/profile'},
            {'text': f"export RETICULATE_PYTHON='{python_path}'"}
        ],
    }

    return config
