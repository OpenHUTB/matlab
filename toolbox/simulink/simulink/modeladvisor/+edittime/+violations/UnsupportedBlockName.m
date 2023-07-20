classdef UnsupportedBlockName<edittime.Violation
    methods
        function self=UnsupportedBlockName(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.MAWarning);
        end

        function createDiagnostic(obj)
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:mathworks_misra_BlockNames_UnsupportedBlockName_Title'));
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:mathworks_misra_BlockNames_UnsupportedBlockName_Description'));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end
        function[map_path,topic_id]=getCSH(obj)
            map_path=['mapkey:',edittime.violations.BlockConstraintViolation.getMisraCshMapKey()];
            topic_id='mathworks.misra.BlockNames';
        end
    end
end
