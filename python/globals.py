import platform
import os

def _get_user_home_dir() -> str:
  """
  Returns the user's home directory path based on the platform.
  On Windows, it retrieves the 'USERPROFILE' environment variable.
  On other platforms, it retrieves the 'HOME' environment variable.
  """

  current_platform = platform.system()
  
  if current_platform == "Windows":
    return os.getenv('USERPROFILE') or ''
  else:
    return os.getenv('HOME') or '' 
    
USER_HOME_DIR: str = _get_user_home_dir()

# Has the menu been initialised yet?
menu_initialised: bool = False