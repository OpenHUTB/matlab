

function highlightParameterInModel(model,blockPath)
    blockHandle=get_param(blockPath,'Handle');
    if blockHandle~=-1

        modelHandle=get_param(model,'Handle');
        if ishandle(modelHandle)
            utils.hiliteAndFade_system(blockHandle,model);
        end
    end
end
