


function checkInspectAsTopSettings(userdata,cbinfo,~)

    studios=slci.toolstrip.util.getAllStudio(cbinfo.studio);

    for i=1:numel(studios)


        studio=studios(i);
        ctx=studio.App.getAppContextManager.getCustomContext('slciApp');
        if strcmp(userdata,'checkForTopModel')
            ctx.setTopModel(true);
        elseif strcmp(userdata,'checkForRefModel')
            ctx.setTopModel(false);
        end
    end
end