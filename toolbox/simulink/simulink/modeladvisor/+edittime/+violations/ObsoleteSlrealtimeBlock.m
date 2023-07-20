classdef ObsoleteSlrealtimeBlock<edittime.Violation




    methods
        function self=ObsoleteSlrealtimeBlock(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.setType(edittime.ViolationType.Error);
            self.createDiagnostic();
        end

        function createDiagnostic(obj)
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:ObsoleteSlrealtimeBlock'));
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:ObsoleteSlrealtimeBlock_cause'));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end

        function size=addToPopupSize(~)
            size=[50,0];
        end

    end
end
