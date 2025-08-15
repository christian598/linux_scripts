#!/usr/bin/env python3

import os
from datetime import datetime
from datetime import timedelta
from pathlib import Path

# Number of days to retain backups
retention_days = 7
# Ensure the backup directory exists
backup_dir = Path("/mnt/data/backup")
backup_dir.mkdir(parents=True, exist_ok=True)

# Ensure the source directory exists
source_dir = Path("/home")
if not source_dir.exists():
    print(f"Directory {source_dir} does not exist.")
    exit(1)

# Create a backup of the source directory and compress using tar

folder_name = source_dir.name
today_str = datetime.now().strftime("%Y-%m-%d")

backup_filename = f"{folder_name}_{today_str}.tar.gz"
backup_path = backup_dir / backup_filename
backup_command = f"/bin/tar -czf {backup_path} -C {source_dir} ." #There was a problem with the tar command (Required the full path to tar).


os.system(backup_command)
print("Backup file will be saved as:", backup_path)

#### Clean up old backups ####

cutoff_date = datetime.now() - timedelta(days=retention_days)

for file in backup_dir.glob(f"{folder_name}_*.tar.gz"):
    file_date_str = file.stem.replace(f"{folder_name}_", "")
    try:
        file_date = datetime.strptime(file_date_str, "%Y-%m-%d")
        if file_date < cutoff_date:
            file.unlink() # delete old file
            print(f"Deleted old backup: {file}")
    except ValueError:
        continue
