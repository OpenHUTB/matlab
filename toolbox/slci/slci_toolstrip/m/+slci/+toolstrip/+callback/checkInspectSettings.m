


function checkInspectSettings(userdata,cbinfo,~)

    value=cbinfo.EventData;

    studios=slci.toolstrip.util.getAllStudio(cbinfo.studio);

    for i=1:numel(studios)


        studio=studios(i);
        ctx=studio.App.getAppContextManager.getCustomContext('slciApp');
        if strcmp(userdata,'checkForTopModel')
            ctx.setTopModel(value);
        elseif strcmp(userdata,'checkForRefModel')
            ctx.setTopModel(~value);
        elseif strcmp(userdata,'checkAllReferencedModel')
            ctx.setFollowModelLinks(value);
        elseif strcmp(userdata,'checkIgnoreModel')
            ctx.setTerminateOnIncompatibility(value);
        elseif strcmp(userdata,'checkSharedUtils')
            ctx.setInspectSharedUtils(value);
        elseif strcmp(userdata,'checkDisableNonInlinedFuncBodyVerification')
            ctx.setDisableNonInlinedFuncBodyVerification(value);
        end
    end
end