classdef DuplicateDataStoreMemoryBlocksSameGraph<edittime.Violation
    methods
        function self=DuplicateDataStoreMemoryBlocksSameGraph(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.Warning);
        end

        function createDiagnostic(obj)
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:DuplicateDataStoreMemoryBlocksSameGraph'));
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:DuplicateDataStoreMemoryBlocksSameGraph_Cause'));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end

    end
end
