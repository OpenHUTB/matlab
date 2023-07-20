function refresh(hdl)



    if isStateflowChart(hdl)
        chartID=sfprivate('block2chart',hdl);
        Stateflow.PropertyInspector.SFObject.propertySetEvent(chartID);
    else
        h=DAStudio.EventDispatcher;
        if strcmp(get_param(hdl(1),'type'),'line')&&isscalar(hdl)

            lineObj=get_param(hdl,'Object');
            line=lineObj.getLine;
            h.broadcastEvent('PropertyChangedEvent',line);
        elseif strcmp(get_param(hdl(1),'type'),'line')

            lineObj=arrayfun(@(x)get_param(x,'Object'),hdl,'UniformOutput',false);
            lines=cellfun(@(x)x.getLine,lineObj,'UniformOutput',false);
            h.broadcastEvent('PropertyChangedEvent',lines{1});
        else

            h.broadcastEvent('PropertyChangedEvent',hdl);
        end
    end
end

function tf=isStateflowChart(hdl)

    if isscalar(hdl)
        tf=strcmp(get_param(hdl,'Type'),'block')&&strcmp(get_param(hdl,'BlockType'),'SubSystem')&&strcmp(get_param(hdl,'SFBlockType'),'Chart');
    else
        tf=false;
    end
end
