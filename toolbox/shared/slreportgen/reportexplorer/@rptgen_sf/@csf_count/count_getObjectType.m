function oType=count_getObjectType(this,objClassName,exampleObj,d)











    dotLoc=findstr(objClassName,'.');
    oType=objClassName(dotLoc(end)+1:end);

