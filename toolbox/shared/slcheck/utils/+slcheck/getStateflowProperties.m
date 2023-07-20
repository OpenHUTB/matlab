function[parentChartName,elementType]=getStateflowProperties(sid)









    parentChartName=sid;
    elementType=slcheck.getStateflowElementType(sid);

    object=Simulink.ID.getHandle(sid);

    if isnumeric(object)
        if Stateflow.SLUtils.isStateflowBlock(object)
            parentChartID=split(sid,':');
            parentChartID=join(parentChartID(1:2),':');
            parentChartName=parentChartID{1};
        end
        return;
    end

    if contains(class(object),'Stateflow')
        chartId=sfprivate('getChartOf',object.id);

        activeInstance=sf('get',chartId,'chart.activeInstance');
        if(activeInstance==0.0)
            h=idToHandle(sfroot,chartId);
            parentChartName=Simulink.ID.getSID(h.Path);
        else
            parentChartName=Simulink.ID.getSID(item.Chart.Path);
        end
    end



end

