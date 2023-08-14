function result=MACanAddBreakPoint(editor,element)


    result=false;
    featVal=slfeature('ConditionalPause');
    if featVal~=2&&featVal~=4
        return;
    end
    bd=bdroot(editor.getDiagram.handle);
    simstatus=get_param(bd,'SimulationStatus');

    if strcmp(simstatus,'stopped')||...
        strcmp(simstatus,'paused')||...
        strcmp(simstatus,'compiled')
        if isa(element,'SLM3I.Segment')
            port=SLStudio.internal.actions.findSegmentOutputPort(element);
            if~isempty(port)
                result=true;
            end
            return;
        end
        if isa(element,'SLM3I.Block')&&featVal==4
            result=true;
            return;
        end
    end
end