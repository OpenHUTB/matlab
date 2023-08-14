function dealWithSFcnPackageMATFiles(matFileName,update,fcnName)







    if~isfile(matFileName)
        return
    end

    loadedData=load(matFileName);
    fields=fieldnames(loadedData);

    for i=1:numel(fields)
        if(isequal(exist(fields{i},'var'),1)&&strcmp(update,'1'))...
            ||isequal(exist(fields{i},'var'),0)
            assignin('base',fields{i},loadedData.(fields{i}));
        elseif(isequal(exist(fields{i},'var'),1)&&strcmp(update,'0'))


            warning('Simulink:SFunctions:SFcnPkgDuplicateVarExists',fcnName,fields{i},matFileName);
        end
    end

end

