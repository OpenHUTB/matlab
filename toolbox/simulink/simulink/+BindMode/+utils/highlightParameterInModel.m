

function highlightParameterInModel(model,blockPath)
    blockHandle=get_param(blockPath,'Handle');
    if blockHandle~=-1

        modelHandle=get_param(model,'Handle');
        if ishandle(modelHandle)
            studios=BindMode.utils.getAllStudiosForModel(modelHandle);
            for idx=1:numel(studios)
                if(~isempty(studios(idx).App))
                    studios(idx).App.hiliteAndFadeObject(diagram.resolver.resolve(blockHandle),1000);
                end
            end
        end
    end
end