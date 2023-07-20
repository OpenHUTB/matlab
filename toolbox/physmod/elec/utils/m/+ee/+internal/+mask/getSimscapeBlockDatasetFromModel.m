function ds=getSimscapeBlockDatasetFromModel(modelName)



    mws=get_param(modelName,'modelworkspace');
    variableList=evalin(mws,'who');
    ds=simscapeBlockDataset.empty;
    for ii=1:length(variableList)
        if isa(evalin(mws,variableList{ii}),'simscapeBlockDataset')
            ds(end+1)=evalin(mws,variableList{ii});%#ok<AGROW>
        end
    end
    if isempty(ds)
        pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:getSimscapeBlockDatasetFromModel:error_ModelWorkspaceSimscapeBlockDataset')));
    end
    if length(ds)>1
        pm_error('physmod:ee:library:TooMany',getString(message('physmod:ee:library:comments:utils:mask:getSimscapeBlockDatasetFromModel:error_ModelWorkspaceSimscapeBlockDatasets')));
    end
end