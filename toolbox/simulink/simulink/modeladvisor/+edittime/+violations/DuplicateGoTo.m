classdef DuplicateGoTo<edittime.Violation
    methods
        function self=DuplicateGoTo(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.Warning);
        end

        function createDiagnostic(obj)
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:DuplicateGoTo'));
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:DuplicateGoTo_Cause'));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end

    end
end
