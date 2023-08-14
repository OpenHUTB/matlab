function handleEditorChanged(obj,~)


    if obj.isvalid
        obj.refresh();
    end

    if coderdictionary.data.feature.getFeature('CodeGenIntent')
        contextManager=obj.studio.App.getAppContextManager;
        ctx=contextManager.getCustomContext('OneCoderApp');
        if~isempty(ctx)
            ctx.updateTypeChain();
        end
    end