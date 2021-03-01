Set up GitLab Personal Access Token in Manage Jenkins > Credentials

Go back to Jenkins and fill in the information similar to what you can see on this screenshot:
![](assets/markdown-img-paste-20210301081324159.png)

Set up Gitlab Branch Source Plugin in Manage Jenkins > Configure System

Still in Jenkins set up a gitlab server:

![](assets/markdown-img-paste-20210301081441453.png)

Create Gitlab checkout credentials Username/Password or SSH

##Again in Jenkins create another checkout credential

![](assets/markdown-img-paste-20210301081508296.png)

In Gitlab Admin Add devops_Jenkins as maintainer to your git projects
![](assets/markdown-img-paste-20210301082932219.png)
`-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABFwAAAAdzc2gtcn
NhAAAAAwEAAQAAAQEAsaD5wKz/doNLdSwq0p0BFALL99D4v7WuCnUdc0PI/btPe/jCyQSk
FaA/43ohTTmwPsiGJCD2DGXBpoegewf2/Zo0sPsZ97lilHAEAYBM5qkLpYDQJ58z2y+MMN
DQ98oitYf9rZTzLiP2qUzcuI1piMmfeoHqJD4LSLjVJcF6Ka1tQ/VQVXtyO0MoAshNwAJ8
0BO2G3EWf+f5/B5l135z/1LJSYhMdTPjZkmnMwsNaZbW74ylRBJIhUgUiNAmGtsu6lAQ37
8t7046j0ACcsXalNB9Ox93QimYTachsNeyCuQda/Bik/SfGRAC5/1srjfBU+Yfu8VwDW8z
sn6+xQ81FwAAA8h9BASAfQQEgAAAAAdzc2gtcnNhAAABAQCxoPnArP92g0t1LCrSnQEUAs
v30Pi/ta4KdR1zQ8j9u097+MLJBKQVoD/jeiFNObA+yIYkIPYMZcGmh6B7B/b9mjSw+xn3
uWKUcAQBgEzmqQulgNAnnzPbL4ww0ND3yiK1h/2tlPMuI/apTNy4jWmIyZ96geokPgtIuN
UlwXoprW1D9VBVe3I7QygCyE3AAnzQE7YbcRZ/5/n8HmXXfnP/UslJiEx1M+NmSaczCw1p
ltbvjKVEEkiFSBSI0CYa2y7qUBDfvy3vTjqPQAJyxdqU0H07H3dCKZhNpyGw17IK5B1r8G
KT9J8ZEALn/WyuN8FT5h+7xXANbzOyfr7FDzUXAAAAAwEAAQAAAQEAsVB9H/5RwW9NCvl9
AeNiqSQlkgsT1OO6iYvhSye2YrrxnFJ1tw6f8UqXnC9VQO6+Zd3sMfKJS1Tkm6U16LrJrt
yZjrYKdQSlSIINLaZynarQCnVs1LCSplFvg2dfwosQXOAUtotCuaOC3fvxNXVMjRSf0z4O
igE5aG3BsD/T//cI4nhOGViB+ymij8+3Ef325fBejOG4W4TIbkcAVT33C9REDRDJvJSE+A
U5jJJBROtYGHc06A4Qar+7KihJ6FCFKV2x89HfXlo/EwjvnBxMRuYVFZPCAk1QGwqPyPu7
zwD24RFJCnKu2L9rWEeymqkF11SmH2ranNU2ydj9PHXVsQAAAIEA5EiuzwwcM2kfHHwrBk
zIWeOVveBmxjI/K+JmtYEqpBcKuBMxVqM1yuwv/SVKcQYxeuun8QzVUMpfdDgES5VfHyrB
+LD1HWfY5N4hz2koQsMGCSuanjH62g6EHexn9YI22jHHXcM/BM7iNeeHG1O2lWMO5asHoh
4MM+ACz+bKxgwAAACBAOmYIEzSl5mWPzYULHinK5Uj9qEBeEztzfXN5aWJd7bPqwwlxNO4
ms1/jnwVUdNnFboO19A5YswQSFyfn6iqckqTSOSo75nu60rQlhHcfzYYJTJzn2xSTFHqAg
tiY1BKFrOe5Fgz9WF77kaDaM91LitSk+Thm6PNd6677p36/KdfAAAAgQDCqqBIQR6xwN/X
/YI/uQfUwrb3vYf9qUNHxIXWUqyHX7AA+OdhEJiQHhfYLauWCqwrNFUYqcz+PXyiHIIXB8
15C/GWMuf/yJRAeKV57+4CSJuLuQOxfZ+iSpMobQybV++IPrDtVjgf31c2UqeE1LjlQZGZ
3cdyCcFXANr5U+VlSQAAAA5kZXZvcHNfamVua2lucwECAw==`{copy}


##Create new Gitlab Group Project
![](assets/markdown-img-paste-20210301082943773.png)

![](assets/markdown-img-paste-20210301082955832.png)

This will generate and periodically check for each and every project you have in Gitlab with Jenkinsefiles
![](assets/markdown-img-paste-20210301083017161.png)
