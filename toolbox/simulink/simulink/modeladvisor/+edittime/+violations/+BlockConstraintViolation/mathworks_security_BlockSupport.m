classdef mathworks_security_BlockSupport<edittime.Violation
    methods
        function self=mathworks_security_BlockSupport(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.MAWarning);
        end

        function createDiagnostic(obj)
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:mathworks_security_BlockSupport_BlockConstraintViolation_Title'));
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:mathworks_security_BlockSupport_BlockConstraintViolation_Description'));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end
        function size=addToPopupSize(obj)
            size=[0,160];
        end
        function[map_path,topic_id]=getCSH(obj)
            if Advisor.Utils.license('test','RTW_Embedded_Coder')
                map_path='mapkey:ma.ecoder';
            elseif Advisor.Utils.license('test','SL_Verification_Validation')
                map_path='mapkey:ma.security';
            end
            topic_id='mathworks.security.BlockSupport';
        end
    end
end
