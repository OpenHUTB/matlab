
function args=getFindVarsArgs(modelToUse)
    if strcmpi(get_param(modelToUse,'SimulationStatus'),'stopped')
        searchMethod='compiled';
    else

        searchMethod='cached';
    end

    args={'SearchMethod',searchMethod,'SearchReferencedModels','on'};
end
