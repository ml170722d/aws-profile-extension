#!/usr/bin/env python
"""Setup script for AWS CLI Profile Extension."""

from setuptools import setup, find_packages

setup(
    name='awscli-plugin-profile',
    version='1.0.0',
    description='AWS CLI extension for quick profile switching with SSO support',
    author='Luka Matovic',
    packages=find_packages(),
    install_requires=[
        'awscli>=1.29.0',
        'boto3>=1.28.0',
        'botocore>=1.31.0',
    ],
    entry_points={
        'console_scripts': [
            'aws-profile=awscli_plugin_profile.cli:main',
        ],
    },
    python_requires='>=3.7',
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: Developers',
        'Natural Language :: English',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
        'Programming Language :: Python :: 3.10',
        'Programming Language :: Python :: 3.11',
    ],
)
