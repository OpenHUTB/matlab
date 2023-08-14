function dirBaseName=getReqSetDirBaseName(reqSetName)
    md5SeedForFolder=...
    slreq.utils.getMD5hash(reqSetName);


    dirBaseName=['HASHSET_',md5SeedForFolder];
end