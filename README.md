# GSP151 — Cloud SQL for MySQL: Qwik Start

This script creates the lab-specified MySQL 8 Cloud SQL instance `myinstance` in `asia-southeast1` with primary zone `asia-southeast1-b`, Development-sized 4 vCPU/16 GB RAM/100 GB SSD storage, then creates the `guestbook` database, `entries` table, and the two required sample rows.

The root password is generated at runtime and is never stored in GitHub. The script prints it at the end for reference.

## Run in Cloud Shell

```bash
curl -LO https://raw.githubusercontent.com/mdshahid000/gsp151-cloud-sql-mysql/main/Meow.sh
sudo chmod +x Meow.sh
./Meow.sh
```

Expected runtime is approximately 4–10 minutes because Cloud SQL instance provisioning can take several minutes. After completion, wait 30–60 seconds and click **Check my progress** for both objectives.
