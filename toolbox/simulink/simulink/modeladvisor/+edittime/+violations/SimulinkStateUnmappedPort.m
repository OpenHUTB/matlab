classdef SimulinkStateUnmappedPort<edittime.Violation
    methods
        function self=SimulinkStateUnmappedPort(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
        end

        function createDiagnostic(obj)
            blkName=get_param(obj.blkHandle,'Name');
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:UnmappedPort'));
            cause=MSLDiagnostic(message('sledittimecheck:edittimecheck:UnmappedPort_Cause',blkName,...
            Simulink.ID.getSID(regexprep(getfullname(obj.blkHandle),'[\n\r]+',' '))));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end

        function size=addToPopupSize(~)
            size=[0,75];
        end
    end
end