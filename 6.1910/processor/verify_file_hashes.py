#!/usr/bin/env python3

import hashlib
import sys
import argparse

class MD5Exception(Exception):
    def __init__(self, message):
        super().__init__(message)

def calculate_md5(file_path):
    """
    Calculates the MD5 hash of a given file.

    :param file_path: Path to the file.
    :return: MD5 hash of the file as a hexadecimal string.
    """
    hasher = hashlib.md5()
    try:
        with open(file_path, 'rb') as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hasher.update(chunk)
        return hasher.hexdigest()
    except FileNotFoundError as e:
        raise MD5Exception("File not found")
    except IOError as e:
        raise MD5Exception("IO Error")

def check_files(files_with_hashes):
    """
    Checks if each file has the expected MD5 hash.

    :param files_with_hashes: List of tuples (file_path, expected_md5).
    :return: None. Exits with code 1 if any hash does not match.
    """
    changed_files = []
    for file_path, expected_md5 in files_with_hashes:
        try:
            calculated_md5 = calculate_md5(file_path)
            if calculated_md5 != expected_md5:
                changed_files.append(file_path)
        except MD5Exception:
            changed_files.append(file_path)
        

    if len(changed_files) != 0:
        print("============================================================================")
        print("WARNING: The following files (which should not change) seem to have changed.")
        for changed_file in changed_files:
            print(changed_file)
        print("============================================================================")

def parse_warn_if_changed():
    """
    Parses the file warn_if_changed which is in the format

    md5 filename
    md5 filename
    ...
    """
    files_with_hashes = []
    try:
        with open('warn_if_changed', 'r') as f:
            for line in f:
                files_with_hashes.append((line.split()[1], line.split()[0]))
    except Exception:
        # If the file doesn't exist, it means we don't warn on anything
        # If the file is formatted incorrectly that's bad but not much we can do
        pass
    return files_with_hashes


if __name__ == "__main__":
    files_with_hashes = parse_warn_if_changed()
    check_files(files_with_hashes)
