

classdef LatchInputParameterConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Inport blocks within triggered subsystems are not permitted to latch inputs by delaying outside signal';
        end

        function obj=LatchInputParameterConstraint()
            obj.setEnum('LatchInputParameter');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            blkSID=aObj.ParentBlock().getSID();
            parentBlk=get_param(blkSID,'Parent');
            parentBlkObj=get_param(parentBlk,'Object');
            isRootLevel=strcmpi(parentBlk,aObj.ParentModel().getName());
            if~isRootLevel&&...
                strcmpi(get_param(parentBlk,'BlockType'),'SubSystem')&&...
                strcmpi(slci.internal.getSubsystemType(parentBlkObj),'Trigger')
                if strcmpi(get_param(blkSID,'LatchByDelayingOutsideSignal'),'on')
                    out=slci.compatibility.Incompatibility(aObj,'LatchInputParameter');
                end
            end
        end

    end
end


