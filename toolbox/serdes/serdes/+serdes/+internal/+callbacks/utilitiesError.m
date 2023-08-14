




function utilitiesError(block,requiredMWSElements)
    mws=get_param(bdroot(block),'ModelWorkspace');
    if isempty(mws)

        serdes.internal.callbacks.deliverInfoNotification(block,'serdes:callbacks:ModelWorkspaceEmpty');
    else

        warnings={};
        for element=1:length(requiredMWSElements)
            if~mws.hasVariable(requiredMWSElements{element})
                warnings{end+1}=requiredMWSElements{element};%#ok<AGROW>
            end
        end
        if~isempty(warnings)

            serdes.internal.callbacks.deliverInfoNotification(block,'serdes:callbacks:ModelWorkspaceMissingParameter',strjoin(warnings,', '));
        end
    end
end

