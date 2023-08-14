function concurrentAccess=isConcurrentAccess(hThis,hData)


    actualDefnObj=hThis.getRefDefnObj;
    concurrentAccess=actualDefnObj.isConcurrentAccess(hData);

