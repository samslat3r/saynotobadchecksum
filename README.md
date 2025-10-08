# Secure S3 Uploads + VirusTotal Scan


## Overview 
This is a demonstration of a fully serverless pipeline for secure file uploads with automaated malware scanning. Currently only supports uploads through a presigned URL. Malicious files are auto-deleted.

Files uploaded through a presigned URL are stored in S3, indexed in DynamoDB, and scanned with VirusTotal. 

Includes modularized terraform resources, python lambdas, and a Github Actions CI pipeline.



## Features

- Secure, presigned S3 file uploads (no public write access)
- File metadata & status info tracked in DynamoDB
- Lambda function to run a VirusTotal scan on upload
- Secrets manager for API keys (natively via Github) - injected post deploy via CI
- CI/CD with Github Actions (OIDC) - deploys to AWS without static credentials
- Unit tests with `pytest` and `moto`


## Architecture

## Stack

## Project Layout

## Quick Start 





