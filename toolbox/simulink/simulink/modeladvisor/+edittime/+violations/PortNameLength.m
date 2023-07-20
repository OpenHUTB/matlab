classdef PortNameLength<edittime.Violation
    methods
        function self=PortNameLength(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.MAWarning);
        end

        function createDiagnostic(obj)
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:mathworks_jmaab_jc_0244_PortNameLength_Title'));
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:mathworks_jmaab_jc_0244_PortNameLength_Description'));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end
        function[map_path,topic_id]=getCSH(obj)
            map_path='mapkey:ma.mw.jmaab';
            topic_id='mathworks.jmaab.jc_0244';
        end
    end
end
