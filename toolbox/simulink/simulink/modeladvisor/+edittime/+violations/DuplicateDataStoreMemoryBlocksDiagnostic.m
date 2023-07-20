classdef DuplicateDataStoreMemoryBlocksDiagnostic<edittime.Violation
    methods
        function self=DuplicateDataStoreMemoryBlocksDiagnostic(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.Warning);
        end

        function createDiagnostic(obj)
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:DuplicateDataStoreMemoryBlocksDiagnostic'));
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:DuplicateDataStoreMemoryBlocksDiagnostic_Cause'));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end

    end
end
