function CustomStorageClassListener(hCoderInfo)















    thisCSC=hCoderInfo.CustomStorageClass;

    cscAttribObject=processcsc('CreateAttributesObject','Simulink',thisCSC);
    cscAttribClass=class(cscAttribObject);


    customstorageclasschanged(hCoderInfo,cscAttribClass);
