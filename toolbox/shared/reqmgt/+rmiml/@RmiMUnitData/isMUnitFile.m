function[isMUnit,isSTMMUnit]=isMUnitFile(filepath)






    munitData=rmiml.RmiMUnitData.getInstance;

    if isKey(munitData.munitCache,filepath)

        status=munitData.munitCache(filepath);
        isMUnit=status.(munitData.IS_MUNIT);
        isSTMMUnit=status.(munitData.IS_STM_MUNIT);
        return;
    end


    isMUnit=rmiml.RmiMUnitData.isGenericMUnitFile(filepath);
    isSTMMUnit=rmiml.RmiMUnitData.isSLTestMUnitFile(filepath);

    munitData.munitCache(filepath)=struct(munitData.IS_MUNIT,isMUnit,...
    munitData.IS_STM_MUNIT,isSTMMUnit);
end
