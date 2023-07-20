classdef NoMatchingGoToTagVisibilityBlock<edittime.Violation
    methods
        function self=NoMatchingGoToTagVisibilityBlock(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.Warning);
        end

        function createDiagnostic(obj)
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:NoMatchingGoToTagVisibilityBlock'));
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:NoMatchingGoToTagVisibilityBlock_Cause'));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end

    end
end
