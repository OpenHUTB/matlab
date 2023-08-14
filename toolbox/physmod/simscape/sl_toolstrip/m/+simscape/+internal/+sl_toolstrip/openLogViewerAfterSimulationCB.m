function openLogViewerAfterSimulationCB(cbinfo,action)





    mdlHandle=simscape.internal.sl_toolstrip.getModelHandle(cbinfo);
    if(~isempty(mdlHandle))
        if(strcmp(get_param(mdlHandle,'SimscapeLogOpenViewer'),'off'))
            set_param(mdlHandle,'SimscapeLogOpenViewer','on');
            action.selected=1;
        else
            set_param(mdlHandle,'SimscapeLogOpenViewer','off');
            action.selected=0;
        end
    end

end