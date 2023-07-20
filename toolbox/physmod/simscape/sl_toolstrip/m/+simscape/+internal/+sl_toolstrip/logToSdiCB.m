function logToSdiCB(cbinfo,action)



    mdlHandle=simscape.internal.sl_toolstrip.getModelHandle(cbinfo);
    if(~isempty(mdlHandle))
        if(strcmp(get_param(mdlHandle,'SimscapeLogToSDI'),'off'))
            set_param(mdlHandle,'SimscapeLogToSDI','on');
            action.selected=1;
        else
            set_param(mdlHandle,'SimscapeLogToSDI','off');
            action.selected=0;
        end
    end
end