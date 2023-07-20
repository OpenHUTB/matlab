function[pValue,propName]=getPropValue(this,objList,propName,objType,isParentPara)










    if ischar(objList)
        objList={objList};
    end

    if nargin<4
        objType=this.getObjectType(objList{1});
    end
    pso=this.getPropSourceObject(objType);
    if isa(pso,'rptgen_sl.propsrc_sl_annotation')
        pso.isParentParagraph=isParentPara;
    end
    [pValue,propName]=getPropValue(pso,objList,propName);