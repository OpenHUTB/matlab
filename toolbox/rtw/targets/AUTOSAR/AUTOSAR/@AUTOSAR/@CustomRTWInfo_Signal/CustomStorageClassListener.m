function CustomStorageClassListener(hCoderInfo)















    thisCSC=hCoderInfo.CustomStorageClass;

    cscAttribObject=processcsc('CreateAttributesObject','AUTOSAR',thisCSC);
    cscAttribClass=class(cscAttribObject);


    customstorageclasschanged(hCoderInfo,cscAttribClass);
