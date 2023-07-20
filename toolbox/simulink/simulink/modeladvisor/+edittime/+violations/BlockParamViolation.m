classdef BlockParamViolation<edittime.Violation
    methods
        function self=BlockParamViolation(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.MAWarning);
        end

        function createDiagnostic(obj)
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:BlockParamViolation'));
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:BlockParamViolation_Cause'));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end

    end
end
