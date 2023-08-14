function[isSupportedFloat,dataType,isSingleType,isDoubleType,isHalfType]=isValidDataType(type)



    isDoubleType=false;
    isSingleType=false;
    isHalfType=false;
    dataType='notFloat';
    isSupportedFloat=false;
    type=type.getLeafType;
    if type.isDoubleType
        isDoubleType=true;
        isSupportedFloat=true;
        dataType='double';
    end
    if type.isSingleType
        isSingleType=true;
        isSupportedFloat=true;
        dataType='single';
    end
    if type.isHalfType
        isHalfType=true;
        isSupportedFloat=true;
        dataType='half';
    end
