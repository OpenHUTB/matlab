classdef FinderDataExporter<slreportgen.webview.DataExporter



    methods
        function h=FinderDataExporter()
            h=h@slreportgen.webview.DataExporter();
            bind(h,'Simulink.Block',@exportSimulinkBlock);
        end
    end

    methods(Access=protected)
        function ret=exportSimulinkBlock(~,obj)
            ret=struct(...
            'blocktype',get(obj,'BlockType'),...
            'masktype',get(obj,'MaskType'));
        end
    end

end