function retVal=getProp(hThis,propName)





    if~isempty(findprop(hThis,propName))
        retVal=get(hThis,propName);
        return;
    end

    actualDefnObj=hThis.getRefDefnObj;


    retVal=actualDefnObj.getProp(propName);





