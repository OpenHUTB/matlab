classdef StateflowStateHandler<dependencies.internal.action.DependencyHandler





    properties(Constant)
        Types=["StateflowState","StateflowTransition","StateflowDataType","StateflowEnumeratedConstant"];
    end

    properties(Constant,Access=private)
        UnsupportedSSIDType=dependencies.internal.graph.Type("UnsupportedSSID");
    end

    methods
        function unhilite=openUpstream(this,dependency)
            location=dependency.UpstreamComponent.Path;
            [~,modelName,~]=fileparts(dependency.UpstreamNode.Location{1});
            try
                unsupportedSSID=dependency.Type.Leaf==this.UnsupportedSSIDType;
                unhilite=i_openUpstreamMayError(location,modelName,unsupportedSSID);
            catch ME
                dependencies.warning('Dialogs:FailedToHighlight',ME.message);
                colon=find(location==':',1,'last');
                block=location(1:colon-1);
                hilite_system(block,"find");
                unhilite=@()hilite_system(block,"none");
            end
        end
    end
end

function unhilite=i_openUpstreamMayError(location,modelName,unsupportedSSID)
    unhilite=@()[];

    import dependencies.internal.util.getStateflowObject;
    obj=getStateflowObject(location,modelName);

    fullsid=Simulink.ID.getStateflowSID(obj);
    if isempty(fullsid)
        if isa(obj.getParent,"Simulink.BlockDiagram")

            daexplr(obj.getParent);
        elseif isa(obj.getParent,"Stateflow.Machine")&&isa(obj.getParent.getParent,"Simulink.BlockDiagram")
            daexplr(obj.getParent.getParent);
        end
        return;
    end

    if unsupportedSSID
        open_system(location);
        return;
    end

    Simulink.ID.hilite(fullsid,"find");
    unhilite=@()Simulink.ID.hilite("");
end
