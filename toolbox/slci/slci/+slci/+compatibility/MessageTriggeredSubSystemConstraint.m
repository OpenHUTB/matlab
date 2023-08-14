


classdef MessageTriggeredSubSystemConstraint<slci.compatibility.Constraint
    methods


        function out=getDescription(aObj)%#ok 
            out='Message triggered subsystems are not supported in SLCI';
        end


        function obj=MessageTriggeredSubSystemConstraint()
            obj.setEnum('MessageTriggeredSubSystem');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end



        function out=check(aObj)
            out=[];
            blkObj=aObj.getOwner().getParam('Object');
            assert(isa(blkObj,'Simulink.SubSystem'));
            if strcmpi(slci.internal.getSubsystemType(blkObj),'messagetrigger')
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'MessageTriggeredSubSystem',...
                aObj.ParentBlock().getName());
            end
        end
    end
end
