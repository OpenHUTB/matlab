classdef CustomDataExporter<slreportgen.webview.DataExporter








    methods
        function h=CustomDataExporter()
            h=h@slreportgen.webview.DataExporter();
            bind(h,'Simulink.Block',@exportSimulink);
            bind(h,'Simulink.BlockDiagram',@exportSimulink);
            bind(h,'Stateflow.Object',@exportStateflow);
        end
    end

    methods
        function data=exportSimulink(h,object)%#ok








            data='<p>data</p>';
        end

        function data=exportStateflow(h,stateflowObject)%#ok
            data='<p>data</p>';
        end
    end
end

