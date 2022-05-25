# gcp-resource-counter

Bash scripts for counting resources within a GCP environment. The result is
a JSON object that describes the resource counts within the specified GCP organization.

## Requirements

In order to run the bash scripts there are a few requirements:

1. Install [Google Cloud CLI][0] (`gcloud`) - minimum version `349.0.0`
2. Enable one of the following APIs and grant the required role/permission to
the user running the resource counting script:
    - [Cloud Asset Inventory API][1] (slower, but free to use). The user
    running the script must have one of these roles at the organization-level:
      - `roles/owner`
      - `roles/cloudasset.owner`
      - `roles/cloudasset.viewer`
    - [Security Command Center][2] (faster, but not free). The user running the
    script must have one of these roles at the organization-level:
      - `roles/resourcemanager.organizationAdmin`
      - `roles/securitycenter.admin`
      - `roles/securitycenter.adminViewer`
3. Install [jq][3]
4. Retrieve the GCP organization ID by running the following command and
looking for the ID of the organization to count:

    ```bash
    gcloud organizations list
    ```

## Authenticate via `gcloud` CLI

1. In a terminal run: `gcloud auth list` to display credentialed accounts
2. Enable the account with the organization-level permissions by running the
command below replacing `ACCOUNT_ID` with the target user/service account ID
from the previous step:

    ```bash
    gcloud config set account ACCOUNT_ID
    ```

## How to run using cloud asset inventory (gcloud_asset_inventory.sh)

```bash
λ organizationID=123456789012 ./gcloud_asset_inventory.sh
{
  "appengine.googleapis.com/Application": 20,
  "cloudfunctions.googleapis.com/CloudFunction": 63,
  "compute.googleapis.com/Image": 43,
  "compute.googleapis.com/Instance": 466,
  "sqladmin.googleapis.com/Instance": 65,
  "storage.googleapis.com/Bucket": 367
}
```

## How to run using security command center (gcloud_scc_inventory.sh)

```bash
λ organizationID=123456789012 ./gcloud_scc_inventory.sh
{
  "appengine.googleapis.com/Application": 20,
  "cloudfunctions.googleapis.com/CloudFunction": 63,
  "compute.googleapis.com/Image": 43,
  "compute.googleapis.com/Instance": 466,
  "sqladmin.googleapis.com/Instance": 65,
  "storage.googleapis.com/Bucket": 367
}
```

## Troubleshooting

### Running cloud asset inventory returns `null`

```bash
λ organizationID=123456789012 ./gcloud_asset_inventory.sh
null
```

Verify IAM for user running asset inventory script has one of the
[roles required](#requirements) and has access to the organization.

### Running security command center returns error

<!-- markdownlint-disable MD013 -->
```bash
ERROR: (gcloud.scc.assets.group) User [your-user-id@your-organization] does not
have permission to access organizations instance [123456789012] (or it may not
exist): Permission 'securitycenter.assets.group' denied on resource
'//cloudresourcemanager.googleapis.com/organizations/123456789012' (or it may
not exist)
```
<!-- markdownlint-enable MD013 -->

[Verify security command center is enabled](4) for the organization. Also verify
IAM for user running security command center script has one of the
[roles required](#requirements) and has access to the organization.

[0]: https://cloud.google.com/sdk/docs/install-sdk
[1]: https://cloud.google.com/asset-inventory/docs/listing-assets
[2]: https://cloud.google.com/security-command-center/docs/set-up
[3]: https://stedolan.github.io/jq/download/
[4]: https://console.cloud.google.com/security/command-center/overview
