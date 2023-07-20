classdef InlineContent<mlreportgen.report.HoleReporter
























    properties












        Content{mlreportgen.report.validators.mustBeInline(Content)}=[];
    end

    methods(Access={?mlreportgen.report.ReporterBase})
        function reporter=InlineContent(varargin)
            reporter=reporter@mlreportgen.report.HoleReporter(varargin{:});
        end
    end

end

