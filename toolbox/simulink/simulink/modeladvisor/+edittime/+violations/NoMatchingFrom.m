classdef NoMatchingFrom<edittime.Violation
    methods
        function self=NoMatchingFrom(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.Warning);
        end

        function createDiagnostic(obj)
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:NoMatchingFrom'));
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:NoMatchingFrom_Cause'));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end

    end
end
