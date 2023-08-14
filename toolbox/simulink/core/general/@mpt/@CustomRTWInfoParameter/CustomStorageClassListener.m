function CustomStorageClassListener(hCoderInfo)





    thisCSC=hCoderInfo.CustomStorageClass;

    correctAttribClass=processcsc('CreateAttributesObject','mpt',thisCSC);
    correctAttribClassName=class(correctAttribClass);


    customstorageclasschanged(hCoderInfo,correctAttribClassName);




