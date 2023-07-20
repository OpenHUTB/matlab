classdef ReportDocument<mlreportgen.dom.LockedDocument


    methods

        function rpt=ReportDocument(rptname,rptFormat,rpttemplate)
            rpt@mlreportgen.dom.LockedDocument(rptname,rptFormat,rpttemplate);
            if isempty(strfind(rpttemplate,'_ja'))
                open(rpt,getKey(rpt));
            else
                open(rpt,getKey_ja(rpt));
            end
        end

    end

    methods(Access=private,Hidden=true)

        function key=getKey(~)







            key='E2DZrtzwQQVTjNCaZzoO17BhUCVSxzhRA8gvcbDwdls50w6qvhp42hwzLaO3ODIZcUUgunAsbNpakxoT2xWXvyDzGo30sExZHkCyuK08bO0/IQikXamhHyKI2hSk3TcZFMjwDX7kpKsfRxP0EHGv5n8/s+LWmL4HHftnEhGxEg==';
        end

        function key=getKey_ja(~)

            key='E2DRo8zwAAVPjMCe134GLJVHFuzK31YFU0jggjKJyfJbN+zKcjbsLWhErqYNTggxmzIPebARbVE8Vo2NR7CncuyrZO531ViBOTSX1/Nfr76f4sjJk25/AHJ4mXqaIIat0ZTisCi2Y5ZOOU5cs6VjttKAtnMQHUZyzhXT+vwUegAN/YwmWg==';
        end

    end

end
