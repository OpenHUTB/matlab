classdef NoMatchingGoTOForTagVisibility<edittime.Violation
    methods
        function self=NoMatchingGoTOForTagVisibility(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.Warning);
        end

        function createDiagnostic(obj)
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:NoMatchingGoTOForTagVisibility'));
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:NoMatchingGoTOForTagVisibility_Cause'));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end

    end
end
