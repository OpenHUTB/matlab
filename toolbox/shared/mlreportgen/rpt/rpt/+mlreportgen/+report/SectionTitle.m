classdef SectionTitle<mlreportgen.report.Title
























































    properties











        OutlineLevel=[];
    end

    methods(Access={?mlreportgen.report.ReporterBase})
        function title=SectionTitle(varargin)









            title=title@mlreportgen.report.Title(varargin{:});
        end
    end

    methods(Access=protected)
        function updateImplTemplateName(title)
            if~isempty(title.OutlineLevel)
                level=title.OutlineLevel;
                if level>6
                    level=6;
                end
                title.Impl.TemplateName=strcat(title.TemplateName,...
                num2str(level));
            end
        end
    end

    methods(Static)
        function path=getClassFolder()
            [path]=fileparts(mfilename('fullpath'));
        end
    end
end

