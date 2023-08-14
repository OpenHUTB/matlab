classdef ModelCoverageDataExporter<slreportgen.webview.DataExporter



    properties(Constant)
        DefaultText=[
        '<table>',10...
        ,'<tr> <td align=center>',10...
        ,'<h3>',getString(message('Slvnv:simcoverage:cvmodelview:InformerDeafultTxt0')),'</h3>',10...
        ,getString(message('Slvnv:simcoverage:cvmodelview:InformerDeafultTxt1')),10...
        ,'</td> </tr>',10...
        ,'</table>',10...
        ];
    end

    properties(Access=private)
        m_cvmap;
    end

    methods
        function h=ModelCoverageDataExporter()
            h@slreportgen.webview.DataExporter();
            bind(h,'Simulink.Line',@noExport);
            bind(h,'Simulink.Object',@exportCoverage);
            bind(h,'Stateflow.Object',@exportCoverage);
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
            if~isempty(h.m_cvmap)
                sid=Simulink.ID.getSID(obj);
                if isKey(h.m_cvmap,sid)
                    ret=h.m_cvmap(sid).text;
                else
                    ret=h.DefaultText;
                end
            else
                ret=h.DefaultText;
            end
        end
    end
end
