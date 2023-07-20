classdef ProductionCodeDeployment<edittime.Violation
    methods
        function self=ProductionCodeDeployment(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.MAWarning);
        end

        function createDiagnostic(obj)
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:ProductionCodeDeployment'));
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:ProductionCodeDeployment_Cause'));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end

        function[map_path,topic_id]=getCSH(obj)
            map_path='mapkey:ma.misrac2012';
            topic_id='MATitlePCGSupport';
        end

    end
end
