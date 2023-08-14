classdef SLFunctionServicesExtract<Sldv.Extract




    methods
        function obj=SLFunctionServicesExtract(utilityName)
            obj=obj@Sldv.Extract(utilityName);
        end

        varargout=extract(obj,block,varargin)
    end

    methods(Access=protected)
        function warningIds=listWarningsToTurnOFF(~)
            warningIds={
            'Simulink:Harness:IndHarnessDetachWarning',...
            'Simulink:Harness:UpdatedConfigSet_GenTypeDefs',...
            'Simulink:Harness:UpdatedConfigSet_SampleTsCheck',...
            'Simulink:Harness:ExportDeleteHarnessFromSystemModel',...
            'Simulink:Harness:HarnessDeletedIndependentHarness',...
            'Simulink:Harness:WarnTermAdded',...
            'Simulink:Harness:InvalidParamValueForSLDVCompatHarness'};
        end
    end
end

