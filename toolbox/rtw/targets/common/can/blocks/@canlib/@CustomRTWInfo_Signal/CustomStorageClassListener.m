function CustomStorageClassListener(hCoderInfo)















    thisCSC=hCoderInfo.CustomStorageClass;

    cscAttribObject=processcsc('CreateAttributesObject','canlib',thisCSC);
    cscAttribClass=class(cscAttribObject);


    customstorageclasschanged(hCoderInfo,cscAttribClass);
