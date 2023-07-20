function MAAddBreakPoint(editor,element,~)

    featVal=slfeature('ConditionalPause');
    if featVal~=2&&featVal~=4
        return;
    end
    bd=editor.getDiagram.handle;
    if isa(element,'SLM3I.Segment')
        port=SLStudio.internal.actions.findSegmentOutputPort(element);
        if~isempty(port)
            portHandle=port.handle;
            SLStudio.ShowAddConditionalPauseDialog(bd,portHandle);
        end
        return;
    end
    if isa(element,'SLM3I.Block')&&featVal==4
        blockHandle=element.handle;
        SLStudio.ShowBlockConditionalPauseDialog(bd,blockHandle);
        return;
    end
end