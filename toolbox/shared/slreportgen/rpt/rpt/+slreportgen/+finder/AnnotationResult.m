classdef AnnotationResult<slreportgen.finder.DiagramElementResult




























    properties(Access=protected,Hidden)
        Reporter=[];
    end

    methods(Access={?slreportgen.finder.AnnotationFinder})
        function this=AnnotationResult(varargin)
            this=this@slreportgen.finder.DiagramElementResult(varargin{:});
            mustBeNonempty(this.Object);
        end
    end

    methods
        function title=getDefaultSummaryTableTitle(~,varargin)






            title=string(getString(message("slreportgen:report:SummaryTable:annotationProperties")));
        end

        function props=getDefaultSummaryProperties(~,varargin)













            props=["Text","AnnotationType","Interpreter"];
        end

        function reporter=getReporter(this)







            if isempty(this.Reporter)
                reporter=slreportgen.report.Annotation(this.Object);
                this.Reporter=reporter;
            else
                reporter=this.Reporter;
            end
        end
    end

end