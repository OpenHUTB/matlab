function CustomStorageClassListener(hCoderInfo)















    thisCSC=hCoderInfo.CustomStorageClass;

    cscAttribObject=processcsc('CreateAttributesObject','ECoderDemos',thisCSC);
    cscAttribClass=class(cscAttribObject);


    customstorageclasschanged(hCoderInfo,cscAttribClass);
