classdef DuplicateGoToTagVisibility<edittime.Violation
    methods
        function self=DuplicateGoToTagVisibility(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.Warning);
        end

        function createDiagnostic(obj)
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:DuplicateGoToTagVisibility'));
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:DuplicateGoToTagVisibility_Cause'));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end

    end
end
