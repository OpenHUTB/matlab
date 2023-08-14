classdef CustomDataExporterFcn<slreportgen.webview.DataExporter








    properties
        SimulinkExportFcn;
        StateflowExportFcn;

        PreExportFcn;
        PostExportFcn;
    end

    methods
        function h=CustomDataExporterFcn()
            h=h@slreportgen.webview.DataExporter();
            bind(h,'Simulink.Block',@exportSimulink);
            bind(h,'Simulink.BlockDiagram',@exportSimulink);
            bind(h,'Stateflow.Object',@exportStateflow);
        end

        function preExport(h,varargin)
            preExport@slreportgen.webview.DataExporter(h,varargin{:});
            if~isempty(h.PreExportFcn)
                feval(h.PreExportFcn,h,varargin{:});
            end
        end

        function postExport(h)
            if~isempty(h.PostExportFcn)
                feval(h.PreExportFcn,h);
            end
            postExport@slreportgen.webview.DataExporter(h);
        end
    end

    methods(Access=private)
        function data=exportSimulink(h,simulinkHandle)
            data=[];
            if~isempty(h.SimulinkExportFcn)
                data=feval(h.SimulinkExportFcn,h,simulinkHandle.Handle);
            end
        end

        function data=exportStateflow(h,stateflowObject)
            data=[];
            if~isempty(h.StateflowExportFcn)
                data=feval(h.StateflowExportFcn,h,stateflowObject);
            end
        end
    end
end

