





classdef LatchInputForFeedbackSignalsConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Inport blocks within Function-call subsystems are not permitted to latch inputs for feedback signal';
        end

        function obj=LatchInputForFeedbackSignalsConstraint()
            obj.setEnum('LatchInputForFeedbackSignals');
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
                strcmpi(slci.internal.getSubsystemType(parentBlkObj),'Function-call')
                if strcmpi(get_param(blkSID,'LatchInputForFeedbackSignals'),'on')
                    out=slci.compatibility.Incompatibility(aObj,'LatchInputForFeedbackSignals');
                end
            end
        end

    end
end


