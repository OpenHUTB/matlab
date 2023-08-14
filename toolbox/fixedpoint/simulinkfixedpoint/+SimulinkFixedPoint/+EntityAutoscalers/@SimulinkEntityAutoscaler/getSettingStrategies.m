function pv=getSettingStrategies(ea,blkObj,pathItem,~)




    pv={};

    blkAttrib=ea.getBlockMaskTypeAttributes(blkObj,pathItem);

    if blkAttrib.IsSettableInSomeSituations

        paramNameOrig=blkAttrib.DataTypeEditField_ParamName;


        dialogParamTracer=SimulinkFixedPoint.TracingUtils.DialogParameterTracer(blkObj,paramNameOrig);



        [blkObjToBeSet,paramNameToBeSet]=dialogParamTracer.getDestinationProperties();


        blockPath=blkObjToBeSet.getFullName;

        pv{1,1}={'FullDataTypeStrategy',blockPath,paramNameToBeSet};
    end
end