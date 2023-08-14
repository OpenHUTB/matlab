classdef mathworks_misra_SwitchDefault<edittime.Violation
    methods
        function self=mathworks_misra_SwitchDefault(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.MAWarning);
        end

        function createDiagnostic(obj)
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:mathworks_misra_SwitchDefault_BlockConstraintViolation_Title'));
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:mathworks_misra_SwitchDefault_BlockConstraintViolation_Description'));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end
        function[map_path,topic_id]=getCSH(obj)
            map_path=['mapkey:',edittime.violations.BlockConstraintViolation.getMisraCshMapKey()];
            topic_id='mathworks.misra.SwitchDefault';
        end

    end
end
