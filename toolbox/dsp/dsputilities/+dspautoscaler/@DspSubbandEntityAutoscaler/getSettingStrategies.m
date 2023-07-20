function pv=getSettingStrategies(h,blkObj,pathItem,~)




    fullMaskParamStr=strcat(h.getSPCUniDTParamPrefixStr([],pathItem),'DataTypeStr');
    blockPath=blkObj.getParent.getFullName;
    pv{1,1}={'FullDataTypeStrategy',blockPath,fullMaskParamStr};
end