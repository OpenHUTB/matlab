classdef DataflowBlockSupportContinuous<edittime.Violation




    methods
        function self=DataflowBlockSupportContinuous(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.setType(edittime.ViolationType.Error);
            self.createDiagnostic();
        end

        function createDiagnostic(obj)
            hBlk=getBlockHandle(obj);
            blockType=get_param(hBlk,'BlockType');
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:DataflowBlockSupportUnsupportedContinuousBlock'));
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:DataflowBlockSupportUnsupportedContinuousBlock_Cause',blockType));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end

        function size=addToPopupSize(~)
            size=[50,0];
        end

    end
end
