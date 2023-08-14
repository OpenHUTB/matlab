classdef WorkspaceExporter<handle



    methods(Static)
        ret=getDefault();
    end

    methods


        function obj=WorkspaceExporter()
            obj.CreatedExporters=Simulink.sdi.Map;
            obj.DefaultElementExporter=Simulink.sdi.internal.export.SignalExporter;
        end

        registerVariableExporter(this,className);

        createPendingExporters(this);
        ret=getDomainExporter(this,domainType);


        [ds,updatedDLO]=exportRun(this,eng,id,bFlatten,varargin)
    end


    properties(Access=private)
        PendingExporters={}
CreatedExporters
DefaultElementExporter
    end
end
