function addListeners(h)





    h.listeners={Simulink.listener(...
    h.daobject,...
    'NameChangeEvent',...
    @(s,e)firePropertyChange(h))};


    ed=DAStudio.EventDispatcher;
    h.listeners(end+1)={handle.listener(...
    ed,...
    'HierarchyChangedEvent',...
    @(s,e)locHierarchyChanged(s,e,h))};
    h.listeners(end+1)={handle.listener(...
    ed,...
    'ChildRemovedEvent',...
    @(s,e)locHierarchyChanged(s,e,h))};

end


function locHierarchyChanged(~,e,h)

    if~isa(h.daobject,'Simulink.SubSystem')
        return;
    end


    myobj=SigLogSelector.SFChartNode.getSFChartObject(h.daobject);


    if~isequal(myobj,e.Source)
        return;
    end

    numChildren=h.childNodes.getCount();
    for idx=1:numChildren
        blk=h.childNodes.getDataByIndex(idx);
        if isempty(blk)||~ishandle(blk)
            continue;
        end
        unpopulate(blk);
        delete(blk);
    end

    h.childNodes.Clear;
    h.populate;
    h.fireHierarchyChanged;

end

