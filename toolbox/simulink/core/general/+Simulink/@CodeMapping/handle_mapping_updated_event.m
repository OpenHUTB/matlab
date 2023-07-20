function handle_mapping_updated_event(~,~,portObj)




    listeners=Simulink.CodeMapping.setGetListeners;
    openHandleIdx=find(listeners{1}==portObj.handle,1);
    if~isempty(openHandleIdx)
        numOfDialogs=length(listeners{3}{openHandleIdx});
        for dialogIdx=1:numOfDialogs
            dialog=listeners{3}{openHandleIdx}(dialogIdx);
            if ishandle(dialog)
                dialog.refresh;
            end
        end
    end
end
