function plist=summ_getPropList(c,filter,objType)











    if nargin<3
        objType=c.LoopType;
    end

    ti=c.summ_getTypeInfo(objType);
    plist=ti.getPropList(filter);


    if strcmpi(objType,'Block')
        plist{end+1}=c.summ_getSplitPropName;
    end
