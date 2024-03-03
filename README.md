
# Terraform Module for a Django Application Infrastructure

This Terraform module is designed to provision a robust, scalable infrastructure tailored for deploying Django applications. It goes beyond merely setting up a Kubernetes cluster by integrating with multiple cloud services to provide a comprehensive solution that includes networking, security, and cloud storage, ensuring your application is highly available, secure, and performant.

## Key Features:

- **Kubernetes Cluster Configuration**: Automated setup of a Kubernetes cluster using the best practices for Django applications, ensuring scalability and manageability.
- **Cloud Integration**: Seamless integration with AWS and Google Cloud Platform (GCP) for resource provisioning, including compute instances, storage buckets, and more, leveraging the strengths of each cloud provider to optimize your infrastructure.
- **Network Security**: Configuration of Cloudflare for advanced security features and protection against DDoS attacks, with automated DNS and CDN setups to enhance your application's security and performance.
- **Storage Solutions**: Setup of cloud storage options (AWS S3, Google Cloud Storage) for static and media files, ensuring fast and secure access to your application's assets.
- **Environment Configuration**: Customizable environment variables and secret management to securely deploy and manage your Django application's configuration.
- **Service Account Management**: Provisioning of service accounts with fine-grained permissions for secure access to cloud resources.

This module provides a solid foundation for deploying Django applications, encapsulating best practices for cloud infrastructure and Kubernetes deployments. It is designed to be flexible, allowing customization to fit your project's specific needs while ensuring that the infrastructure's security and performance are not compromised.

## Usage

To use this module in your Terraform configuration, use the following syntax:

```hcl
module "django_app_kubernetes" {
  source = "path/to/this/module"

  // Variables
  project_id   = "<your-project-id>"
  cluster_name = "<your-cluster-name>"
  region       = "<your-region>"

  // Add other required variables
}
```

Replace the placeholders with actual values according to your project's requirements.

## Examples

Refer to the `examples/` directory for more examples.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| [provider] | >= [version] |

## Providers

The following providers are used by this module:

| Name | Version | Source |
|------|---------|--------|
| kubernetes | >= 2.4.0 | hashicorp/kubernetes |
| cloudflare | >= 2.0.0 | cloudflare/cloudflare |
| aws | >= 3.0.0 | hashicorp/aws |
| google | >= 3.0.0 | hashicorp/google |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name for deployment | string | "django" | no |
| namespace | Kubernetes namespace to use with this installation | string | n/a | no |
| create_namespace | Should we create the namespace or use existing provided? | string | true | no |
| extra_labels | Extra labels to add to generated objects | map(string) | {} | no |
| image_name | Docker image repository and name | string | n/a | no |
| image_tag | Docker image tag | string | n/a | no |
| image_pull_secrets | Image pull secrets | list(string) | [] | no |
| image_pull_policy | Pull policy for the images | string | "IfNotPresent" | no |
| env | A map of extra environment variables | map(string) | {} | no |
| secret_env | A map of extra secret environment variables | map(string) | {} | no |
| service_account_name | Name of the kubernetes service account if any | string | null | no |
| cloud_sa_name | Name of the GCP/AWS service account if any | string | null | no |
| gcp_sa_extra_roles | Create role bindings to these roles | list(string) | null | no |
| gcp_bucket_name | Create and use Google storage with this name | string | null | no |
| gcp_bucket_location | The location of the bucket, e.g. EU or US | string | n/a | no |
| public_storage | Make the storge GCP bucket/AWS S3 public and create a CNAME | bool | true | no |
| gcp_add_aws_s3_env | Add AWS_ variables for the GCS bucket | bool | false | no |
| gcp_db_instance | Create a database and a user for this installation and use them instead of DATABASE_URL | string | null | no |
| deployments |  | map(object({ | { | no |
| readiness_probe | Readiness probe for containers which have ports | object({ | { | no |
| liveness_probe | Liveness probe for containers which have ports | object({ | { | no |
| ingress | A map of hostnames with maps of path-names and services | map(map(string)) | { | no |
| ingress_annotations |  | map(string) | {} | no |
| cloudflare_enabled | Create cloudflare records if true | bool | true | no |
| postgres_enabled | Create a postgres database deployment | bool | false | no |
| postgres_storage_size |  | string | "10Gi" | no |
| postgres_resources_requests_memory |  | string | "256Mi" | no |
| postgres_resources_requests_cpu |  | string | "250m" | no |
| postgres_resources_limits_memory |  | string | null | no |
| postgres_resources_limits_cpu |  | string | null | no |
| redis_enabled | Create a redis database deployment | bool | false | no |
| redis_resources_limits_memory |  | string | null | no |
| redis_resources_limits_cpu |  | string | null | no |
| redis_resources_requests_memory |  | string | "128Mi" | no |
| redis_resources_requests_cpu |  | string | "50m" | no |
| redis_db_index |  | string | "1" | no |
| celery_enabled | A short-hand for adding celery-beat and celery-worker deployments | string | true | no |
| celery_db_index |  | string | "2" | no |
| celery_beat_defaults |  | string | { | no |
| celery_worker_defaults |  | string | { | no |
| aws_s3_name | Create and use AWS S3 | string | null | no |
| volumes | Volume configuration | any | [] | no |
| security_context_enabled |  | bool | false | no |
| security_context_gid |  | number | 101 | no |
| security_context_uid |  | number | 101 | no |
| security_context_fsgroup |  | string | null | no |
| aws_region | AWS region | string | "" | no |
| cloudflare_api_token | Cloudflare API token | string | "12321321332145325-435325432543254325-4532542353254325-" | no |
| gcp_region | GCP region | string | "" | no |
| database_url | Database URL | string | "" | no |
| redis_url | Redis URL | string | "" | no |
| aws_secret | AWS secret | string | "" | no |
| aws_id | AWS id | string | "" | no |
| aws_s3_endpoint_url | AWS S3 endpoint URL | string | "" | no |
| gcp_access_id | GCP access id | string | "" | no |
| gcp_secret | GCP secret | string | "" | no |
| service_account_email | Service account email | string | "example@project.iam.gserviceaccount.com" | no |
| gcp_project_id | The GCP project ID | string | n/a | no |


## Outputs

| Name | Description |
|------|-------------|
| database_url |  |
| google_storage_hmac_key |  |
| postgresql_url |  |
| postgresql_username |  |
| postgresql_password |  |
| redis_url |  |
| redis_password |  |
| s3_endpoint_url |  |
| s3_access_key |  |
| s3_endpoint_url |  |
| s3_access_key |  |


## Authors

Originally created by ahernper.

