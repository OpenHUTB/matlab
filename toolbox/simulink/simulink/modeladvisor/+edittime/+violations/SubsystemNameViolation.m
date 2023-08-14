classdef SubsystemNameViolation<edittime.Violation
    methods
        function self=SubsystemNameViolation(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.MAWarning);
        end

        function createDiagnostic(obj)
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:SubsystemNameViolation'));
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:SubsystemNameViolation_Cause'));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end

        function[map_path,topic_id]=getCSH(obj)
            map_path='mapkey:ma.mw.jmaab';
            topic_id=obj.getCheckID();
        end

    end
end
