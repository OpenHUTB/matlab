classdef CodeGenSupport<edittime.Violation
    methods
        function self=CodeGenSupport(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.MAWarning);
        end

        function createDiagnostic(obj)
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:CodeGenSupport'));
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:CodeGenSupport_Cause'));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end

        function[map_path,topic_id]=getCSH(obj)
            map_path='mapkey:ma.misrac2012';
            topic_id='MATitlePCGSupport';
        end
    end
end
