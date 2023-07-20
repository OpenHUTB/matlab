classdef PortNameViolation<edittime.Violation
    methods
        function self=PortNameViolation(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.MAWarning);
        end

        function createDiagnostic(obj)
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:PortNameViolation'));
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:PortNameViolation_Cause'));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end

        function[map_path,topic_id]=getCSH(obj)
            map_path='mapkey:ma.mw.jmaab';
            topic_id=obj.getCheckID();
        end

    end
end
