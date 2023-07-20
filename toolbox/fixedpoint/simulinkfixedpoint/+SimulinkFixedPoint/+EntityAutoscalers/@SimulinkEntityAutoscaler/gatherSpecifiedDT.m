function[DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)





    paramNames.modeStr='';
    paramNames.wlStr='';
    paramNames.flStr='';
    hBlk=blkObj.Handle;
    blkAttrib=h.getBlockMaskTypeAttributes(blkObj,pathItem);

    if isfield(blkAttrib,'DataTypeEditField_ParamName')

        paramNames.modeStr=blkAttrib.DataTypeEditField_ParamName;

    end

    comments={};

    DTStr='';
    if~blkAttrib.IsSettableInSomeSituations...
        &&~isfield(blkAttrib,'DataTypeEditField_ParamName')...
        &&isfield(blkAttrib,'DisplayDataTypeStr')

        DTStr=blkAttrib.DisplayDataTypeStr;

    elseif isfield(blkAttrib,'DataTypeEditField_ParamName')

        DTStr=get_param(hBlk,blkAttrib.DataTypeEditField_ParamName);

    end

    DTConInfo=SimulinkFixedPoint.DTContainerInfo(DTStr,blkObj);

end




