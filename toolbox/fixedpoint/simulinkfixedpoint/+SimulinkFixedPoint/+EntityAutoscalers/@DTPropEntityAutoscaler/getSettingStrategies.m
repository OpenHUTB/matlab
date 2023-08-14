function pv=getSettingStrategies(h,blkObj,~,~)




    pv={};
    paramNameOrig='PropDataType';
    paramNameToBeSet=paramNameOrig;
    blkObjToBeSet=blkObj;

    if h.isUnderMaskWorkspace(blkObj)||SimulinkFixedPoint.TracingUtils.IsUnderLibraryLink(blkObj)

        if isUnderLibraryDynamicSaturation(blkObj)


            blkObj=blkObj.getParent;
            paramNameOrig='OutDataTypeStr';
        end


        dialogParamTracer=SimulinkFixedPoint.TracingUtils.DialogParameterTracer(blkObj,paramNameOrig);



        [blkObjToBeSet,paramNameToBeSet]=dialogParamTracer.getDestinationProperties();

    end

    blockPath=blkObjToBeSet.getFullName;
    pv{1,1}={'FullDataTypeStrategy',blockPath,paramNameToBeSet};

end

function isPartOfDynamicSaturation=isUnderLibraryDynamicSaturation(blockObject)

    parentObject=blockObject.getParent;
    isPartOfDynamicSaturation=isa(parentObject,'Simulink.SubSystem')&&strcmp(parentObject.MaskType,'Saturation Dynamic');
end


