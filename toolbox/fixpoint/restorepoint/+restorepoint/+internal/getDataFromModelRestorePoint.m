function[data,success]=getDataFromModelRestorePoint(model)






    success=false;
    restorePoint=restorepoint.internal.utils.getExistingRestorePointDirectoryForModel(model);
    savedVariables=fullfile(restorePoint,'customvariables.mat');
    if exist(savedVariables,'file')
        storedData=load(savedVariables);
        data=storedData.data;
        success=true;
    else
        data=struct.empty;
    end
end


