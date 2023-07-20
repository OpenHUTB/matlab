



classdef NestedSimulinkFunctionConstraint<slci.compatibility.Constraint
    methods

        function out=getDescription(aObj)%#ok
            out=['SLCI does not support Simulink Function defined '...
            ,'inside Simulink Function'];
        end


        function obj=NestedSimulinkFunctionConstraint()
            obj.setEnum('NestedSimulinkFunction')
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            sub=aObj.getOwner;
            assert(isa(sub,'slci.simulink.SubSystemBlock'),...
            "This block is not a Subsystem")
            blkObj=get_param(sub.getHandle,'Object');
            assert(strcmp(blkObj.IsSimulinkFunction,'on'))
            parentObj=get_param(blkObj.Parent,'Object');
            while~isa(parentObj,'Simulink.BlockDiagram')
                if isa(parentObj,'Simulink.SubSystem')&&...
                    strcmp(parentObj.IsSimulinkFunction,'on')
                    out=slci.compatibility.Incompatibility(aObj,...
                    aObj.getEnum(),...
                    aObj.ParentModel().getName());
                    return;
                end
                parentObj=get_param(parentObj.Parent,'Object');
            end

        end
    end

end