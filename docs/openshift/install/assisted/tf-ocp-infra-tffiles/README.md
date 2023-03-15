Terrform scrip to create OCP VMs on Nutanix HCI. Just creates master and worker VMs. This can be used with OCP Assisted Install procedure to create OCP cluster.

Variables file takes the RHOCS ISO as bootmedia. This bootmedia will be uploaded to AHV images and be used to boot the VMs. 

# tf-ocp-infra

1. Clone this repo
2. Change variables file with your environment values. There is a sample variables file.
3. Sequence of commands
   
   ```bash
   
    # terraform init
    # terraform plan
    # terraform apply
   
   ```
   
 ## Helpful commands
 
  ```bash
 
   # terraform state list
   # terraform state rm <resource name>
 
  ```
