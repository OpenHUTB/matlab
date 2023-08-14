function success=addDataToModelRestorePoint(model,data)






    success=false;

    if(~isa(data,'struct')||isempty(data))
        return;
    end

    storeDir=restorepoint.internal.utils.getExistingRestorePointDirectoryForModel(model);


    if~isempty(storeDir)
        fullStorePath=fullfile(storeDir,'customvariables.mat');
        save(fullStorePath,'data');
        success=true;
    end
end


