function children=getChildrenForSystem(~,sysName)




    bdObj=get_param(sysName,'Object');
    chartObj=[];
    if fxptds.isSFMaskedSubsystem(bdObj)
        chartObj=fxptds.getSFChartObject(bdObj);
    end
    children=bdObj.getHierarchicalChildren;
    if~isempty(children)
        children=find(children,'-depth',0,'-isa','Stateflow.Chart',...
        '-or','-isa','Stateflow.LinkChart',...
        '-or','-isa','Stateflow.EMChart',...
        '-or','-isa','Stateflow.TruthTableChart',...
        '-or','-isa','Stateflow.ReactiveTestingTableChart',...
        '-or','-isa','Stateflow.StateTransitionTableChart',...
        '-or','-isa','Simulink.SubSystem',...
        '-or','-isa','Simulink.ModelReference');
        if~isempty(chartObj)
            idx=find(children==chartObj);
            if~isempty(idx)
                children(idx)=[];
            end
        end
    end
end
