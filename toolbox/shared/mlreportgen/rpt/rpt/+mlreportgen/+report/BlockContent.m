classdef BlockContent<mlreportgen.report.HoleReporter
























    properties




        Content{mlreportgen.report.validators.mustBeBlock(Content,"Content")}=[];
    end

    methods(Access={?mlreportgen.report.ReporterBase})
        function reporter=BlockContent(varargin)
            reporter=reporter@mlreportgen.report.HoleReporter(varargin{:});
        end
    end

end

