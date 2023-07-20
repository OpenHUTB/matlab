classdef NoMatchingGoTO<edittime.Violation
    methods
        function self=NoMatchingGoTO(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.Warning);
        end

        function createDiagnostic(obj)
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:NoMatchingGoTO'));
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:NoMatchingGoTO_Cause'));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end

    end
end
