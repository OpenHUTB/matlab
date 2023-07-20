classdef mathworks_jmaab_jc_0630<edittime.Violation
    methods
        function self=mathworks_jmaab_jc_0630(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.MAWarning);
        end

        function createDiagnostic(obj)
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:mathworks_jmaab_jc_0630_BlockConstraintViolation_Title'));
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:mathworks_jmaab_jc_0630_BlockConstraintViolation_Description'));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end

        function size=addToPopupSize(obj)
            size=[0,150];
        end

        function[map_path,topic_id]=getCSH(obj)
            map_path='mapkey:ma.mw.jmaab';
            topic_id='mathworks.jmaab.jc_0630';
        end
    end
end
