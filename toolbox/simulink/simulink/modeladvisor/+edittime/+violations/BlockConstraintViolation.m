classdef BlockConstraintViolation<edittime.Violation
    properties
blkHandle
system
checkID
    end

    methods
        function self=BlockConstraintViolation(system,blkHandle,checkId)
            self=self@edittime.Violation();
            self.blkHandle=blkHandle;
            self.system=system;
            self.checkID=checkId;
            self.createDiagnostic();
            self.setType(edittime.ViolationType.MAWarning);
        end

        function createDiagnostic(obj)
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:IssueWithCheck',obj.checkID));
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:BlockNameViolation_Cause'));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end

    end
end
