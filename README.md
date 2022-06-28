# Using Jenkins to Test & Deploy to RStudio Connect 

RStudio Connect hosts a variety of data artifacts with different development 
life cycles. Whenever you want to publish one of these data artifacts to RStudio 
Connect, there are three paths you can follow:

 - Push-button deployment process within the RStudio IDE
 - Git-backed deployment within RStudio Connect
 - Programmatic deployment

This repository is an example of the third deployment path using Jenkins as
a CI/CD pipeline to test and deploy a Shiny application hosted on GitHub to RStudio Connect. 

If you want to learn more about it you can read: [https://solutions.rstudio.com/data-science-admin/deploy/jenkins/](https://solutions.rstudio.com/data-science-admin/deploy/jenkins/)