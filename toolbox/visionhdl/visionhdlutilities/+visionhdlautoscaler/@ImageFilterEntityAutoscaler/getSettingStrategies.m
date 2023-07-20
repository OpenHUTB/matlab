function pv=getSettingStrategies(ea,blkObj,pathItem,~)




    udtMaskParamStr=strcat(getSPCUniDTParamPrefixStr(ea,blkObj,pathItem),'DataTypeStr');


    blockPath=blkObj.getFullName;
    pv{1,1}={'FullDataTypeStrategy',blockPath,udtMaskParamStr};
end

