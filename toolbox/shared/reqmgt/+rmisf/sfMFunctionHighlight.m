function sfMFunctionHighlight(sid,hasLinks)
    mfHandle=Simulink.ID.getHandle(sid);
    if isa(mfHandle,'Stateflow.Object')
        if hasLinks
            style=sf_style('req');
        else
            style=sf_style('none');
        end
        sf_set_style(mfHandle.Id,style);



        chartH=sf('Private','chart2block',mfHandle.Chart.Id);
        if hasLinks
            if strcmp(get_param(chartH,'HiliteAncestors'),'fade')
                set_param(chartH,'HiliteAncestors','reqInside');
            end
        else
            if strcmp(get_param(chartH,'HiliteAncestors'),'reqInside')
                set_param(chartH,'HiliteAncestors','off');
            end
        end
    else
        if hasLinks
            set_param(mfHandle,'HiliteAncestors','reqInside');
        else
            set_param(mfHandle,'HiliteAncestors','none');
        end
    end
end

