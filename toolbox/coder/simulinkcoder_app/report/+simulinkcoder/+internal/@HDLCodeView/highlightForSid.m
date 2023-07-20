function highlightForSid(obj,sid,isStateFlowObj)




    traceInfo=obj.getTraceInfoObj();
    fileLineData=obj.getSidToFileLineData(sid,traceInfo,isStateFlowObj);
    if~isfield(fileLineData,'error')
        input.data=fileLineData;
        if isStateFlowObj
            h=Simulink.ID.getHandle(sid);
            if isprop(h,'Name')
                input.title=h.Name;
            else
                input.title=class(h);
            end
        else
            input.title=get_param(sid,'name');
        end
    else
        input.title=fileLineData.error;
        input.data=[];
    end
    obj.publish('highlight',input);
end

