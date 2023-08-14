function out=getComponentList(obj)




    if isempty(obj.compList)
        cs=obj.getCS;
        mcs=configset.internal.getConfigSetStaticData;
        out=loc_getAllComponentsInConfigSet(cs,mcs);
        obj.compList=out;
    else
        out=obj.compList;
    end

    function comps=loc_getAllComponentsInConfigSet(cs,mcs)


        cls=class(cs);
        if mcs.ComponentMap.isKey(cls)
            comps={mcs.getComponent(cls).Name};
        else
            comps={};
        end

        if isa(cs,'Simulink.STFCustomTargetCC')...
            &&strcmp(cs.ForcedBaseTarget,'on')
            return;
        end

        for i=1:length(cs.Components)
            cc=cs.Components(i);
            comps=[comps,loc_getAllComponentsInConfigSet(cc,mcs)];%#ok
        end