function pv=getSettingStrategies(~,blkObj,~,~)




    blockPath=blkObj.getFullName;
    pv{1,1}={'FullDataTypeStrategy',blockPath,'OutDataTypeStr'};
end