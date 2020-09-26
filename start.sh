#!/bin/sh

export ISU_APP_PORT=5000
export ISU_DB_HOST=10.146.15.221
export ISU_DB_PORT=3306
export ISU_DB_USER=isucon
export ISU_DB_PASSWORD=isucon
export ISU_DB_NAME=isucoin
export ISU_PUBLIC_DIR=public

exec ./isucoin
