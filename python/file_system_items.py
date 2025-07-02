import os

class FileSystemItem:
  path: str

  def __init__(self, path) -> None:
    self.path = path

class File(FileSystemItem):
  def read_lines(self) -> list[str]:
    with open(self.path, 'r') as file:
      return file.readlines()
  
  def read_as_string(self) -> str:
    with open(self.path, 'r') as file:
      return file.read()

class Directory(FileSystemItem):
  def list(self) -> list[FileSystemItem]:
    return [
      File(
        os.path.join(self.path, item)
      )
        if os.path.isfile(os.path.join(self.path, item))
        else Directory(os.path.join(self.path, item))
      for item in os.listdir(self.path)
    ]
