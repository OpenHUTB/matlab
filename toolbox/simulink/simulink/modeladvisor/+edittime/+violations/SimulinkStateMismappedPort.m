classdef SimulinkStateMismappedPort<edittime.Violation
    methods
        function self=SimulinkStateMismappedPort(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
        end

        function createDiagnostic(obj)
            blkName=get_param(obj.blkHandle,'Name');
            subsys=get_param(obj.blkHandle,'parent');
            subsysObj=get_param(subsys,'Object');
            manager=Stateflow.SLINSF.SimulinkMan.getManagerFromSubsystem(subsysObj);
            chartObj=sf('IdToHandle',manager.chartId);
            stateflowObj=chartObj.find('-isa','Stateflow.Data','Name',blkName,'-depth',2);

            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:MismappedPort'));
            cause=MSLDiagnostic(message('Stateflow:slinsf:MismappedPortSimulinkEditTimeFixDescription',blkName,stateflowObj.Scope));
            obj.diagnostic=obj.diagnostic.addCause(cause);
        end

        function size=addToPopupSize(~)
            size=[0,25];
        end

    end
end