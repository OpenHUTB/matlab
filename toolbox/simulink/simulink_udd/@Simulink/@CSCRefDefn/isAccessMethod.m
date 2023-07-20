function result=isAccessMethod(hThis,hData)




    actualDefnObj=hThis.getRefDefnObj;

    if(nargin==1)
        result=actualDefnObj.isAccessMethod;
    else
        result=actualDefnObj.isAccessMethod(hData);
    end



