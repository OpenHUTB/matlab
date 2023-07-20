function pv=getSettingStrategies(h,blkObj,pathItem,~)




    udtMaskParamStr=strcat(getSPCUniDTParamPrefixStr(h,blkObj,pathItem),'DataTypeStr');
    blockPath=blkObj.getFullName;
    pv{1,1}={'FullDataTypeStrategy',blockPath,udtMaskParamStr};
end