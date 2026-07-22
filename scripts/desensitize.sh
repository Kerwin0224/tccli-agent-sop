#!/usr/bin/env bash
# 脱敏：stdin → stdout。mask 资源 ID / IP / 密钥 / 账号标识，避免泄漏到公开 issue。
# 用法: desensitize.sh < raw.txt > masked.txt
# 注：不用 \b（BSD sed 不支持）；字符类用 [[:space:]] 而非 \s（macOS BSD sed 下 \s 不可靠）。
set -euo pipefail

sed -E \
  -e 's/(ins-)[A-Za-z0-9]+/\1******/g' \
  -e 's/(cls-)[A-Za-z0-9]+/\1******/g' \
  -e 's/(vpc-)[A-Za-z0-9]+/\1******/g' \
  -e 's/(subnet-)[A-Za-z0-9]+/\1******/g' \
  -e 's/(pcx-)[A-Za-z0-9]+/\1******/g' \
  -e 's/(sg-)[A-Za-z0-9]+/\1******/g' \
  -e 's/(rtb-)[A-Za-z0-9]+/\1******/g' \
  -e 's/(eip-)[A-Za-z0-9]+/\1******/g' \
  -e 's/(disk-)[A-Za-z0-9]+/\1******/g' \
  -e 's/(snap-)[A-Za-z0-9]+/\1******/g' \
  -e 's/(img-)[A-Za-z0-9]+/\1******/g' \
  -e 's/(eni-)[A-Za-z0-9]+/\1******/g' \
  -e 's/(ckafka-|cmq-|cdb-|cfs-|clb-|cos-|crs-|cynosdb-|dcx-|dcg-|es-|gaap-|keewidb-|lighthouse-|mariadb-|mongodb-|postgres-|redis-|sqlserver-|tbase-|tdmq-|tdsql-|tke-|tse-|vod-|waf-)[A-Za-z0-9]+/\1******/g' \
  -e 's/([Ss]ecret[Ii]d["'"'"']?[[:space:]]*[:=][[:space:]]*"?)[A-Za-z0-9/+_-]+/\1****/g' \
  -e 's/([Ss]ecret[Kk]ey["'"'"']?[[:space:]]*[:=][[:space:]]*"?)[A-Za-z0-9/+_-]+/\1****/g' \
  -e 's/AKID[A-Za-z0-9]{10,}/AKID****/g' \
  -e 's/([Uu]in["'"'"']?[[:space:]]*[:=][[:space:]]*"?)[0-9]{5,}/\1****/g' \
  -e 's/([Aa]pp[Ii]d["'"'"']?[[:space:]]*[:=][[:space:]]*"?)[0-9]{5,}/\1****/g' \
  -e 's/(^|[^A-Za-z])([Uu]in|[Aa]pp[Ii]d)[[:space:]]+[0-9]{5,}/\1\2 ****/g' \
  -e 's/[0-9]{1,3}(\.[0-9]{1,3}){3}/***.***.***.***/g' \
  -e 's/([0-9a-fA-F]{0,4}:){2,7}[0-9a-fA-F]{0,4}/***:****:****/g' \
  -e 's/([Aa]uthorization["'"'"']?[[:space:]]*[:=][[:space:]]*"?).*/\1****/g' \
  -e 's/[Bb]earer[[:space:]]+[A-Za-z0-9._=+-]+/Bearer ****/g' \
  -e 's/eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+/****/g' \
  -e 's/([Tt]oken["'"'"']?[[:space:]]*[:=][[:space:]]*"?)[A-Za-z0-9/+_.=-]+/\1****/g' \
  -e 's/([?&]((access_)?token|key|password|secret)=)[^&[:space:]]+/\1****/gi' \
  -e 's/(^|[[:space:]"'"'"'])(((access_)?token|password|secret)=)[^&[:space:]"'"'"']+/\1\2****/gi'
