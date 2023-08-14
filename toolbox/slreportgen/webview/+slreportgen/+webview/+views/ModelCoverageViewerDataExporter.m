classdef ModelCoverageViewerDataExporter<slreportgen.webview.DataExporter



    properties(Constant)
        MissingColor='red';
        FullColor='green';
        FilteredColor='gray';
    end

    properties
        m_cvmap;
    end

    methods
        function h=ModelCoverageViewerDataExporter()
            h=h@slreportgen.webview.DataExporter();
            bind(h,'Simulink.Object',@exportCoverage);
            bind(h,'Simulink.Line',@noExport);
            bind(h,'Stateflow.Object',@exportStateflowCoverage);
            bind(h,'Stateflow.Chart',@exportCoverage);
        end

        function preExport(h,varargin)
            preExport@slreportgen.webview.DataExporter(h,varargin{:});
            h.m_cvmap=getCoverageMap(h.ViewExporter);
        end

        function postExport(h)
            h.m_cvmap=[];
            postExport@slreportgen.webview.DataExporter(h);
        end
    end

    methods(Access=private)
        function ret=exportCoverage(h,obj)
            ret=[];
            sid=Simulink.ID.getSID(obj);
            if(~isempty(h.m_cvmap)&&isKey(h.m_cvmap,sid))
                ret=struct('color',getColor(h,h.m_cvmap(sid)));
            end
        end

        function ret=exportStateflowCoverage(h,obj)
            ret=[];
            sid=Simulink.ID.getSID(obj);
            if(~isempty(h.m_cvmap)&&isKey(h.m_cvmap,sid))
                ret=struct('style',[
                'stroke: ',getColor(h,h.m_cvmap(sid)),';'...
                ,'stroke-opacity: 1; '...
                ,'stroke-width: 4; '...
                ,'stroke-linejoin: miter; '...
                ,'stroke-dasharray: none']);
            end
        end

        function color=getColor(h,covMapItem)
            switch covMapItem.color
            case 'full'
                color=h.FullColor;
            case 'missing'
                color=h.MissingColor;
            otherwise
                color=h.FilteredColor;
            end
        end
    end
end

