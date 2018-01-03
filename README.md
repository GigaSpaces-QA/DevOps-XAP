# Overview

This repository contains some tools that facilitate the building process of old builds.

The main goal of these tools is to apply some changes on specific branches with one click.

Each script clones the required branch to a temporary directory under the current working directory, makes the changes, shows the diff before committing and asks for confirmation, commits and pushes the changes to the remote directory. 
If an error occurs the script will exit.
Once the script finishes (also on error), it asks the user if he want to delete the temporary directory.

## Updating the license

Description: 

Updates the gslicene.xml or xap-license.txt with a new and valid license (license should be provided as parameter).

Syntax:
```bash
./updatelicense "<branch_name>" "<license_key>"
```
***It is important to use double quotes for the license key as it contains spaces/semicolons.**


## Updating HTTP Session project

Description: 

xap-session-sharing-manager project builds shiro modules as part of the build process. These shiro modules use a SNAPSHOT version of other shiro modules which is bad. We have uploaded a good version of these modules to our maven repository so we don't need build them. The script simply remove three modules from the root pom.xml file.

Syntax:

```bash
./updatehttpsession "<branch_name>"
```

## Updating S3 bucket name (dotnet)

Description: 

Dotnet project uploads the msi to S3. In October 2017 we changed the bucket name. This script simply updates the bucket name in the deployS3 script.

**This applies to branches after 12.0.0**

Syntax:

```bash
./updatedotnets3.sh "<branch_name>"
```
