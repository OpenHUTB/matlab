function pv=getSettingStrategies(h,blkObj,pathItem,proposedDT)%#ok<INUSL>




    pv={};



    if SimulinkFixedPoint.DataTypeContainer.isStringBuiltInFloat(proposedDT)
        blockPath=blkObj.getFullName;
        paramNameToBeSet='DataType';
        pv{1,1}={'FullDataTypeStrategy',blockPath,paramNameToBeSet};

    end

end