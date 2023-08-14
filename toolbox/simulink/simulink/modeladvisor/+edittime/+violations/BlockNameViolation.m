classdef BlockNameViolation<edittime.Violation
    methods
        function self=BlockNameViolation(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.MAWarning);
        end

        function createDiagnostic(obj)
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:BlockNameViolation'));
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:BlockNameViolation_Cause'));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end

        function[map_path,topic_id]=getCSH(obj)
            map_path='mapkey:ma.mw.jmaab';
            topic_id=obj.getCheckID();
        end

    end
end
