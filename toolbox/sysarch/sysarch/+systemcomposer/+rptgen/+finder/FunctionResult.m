classdef FunctionResult<mlreportgen.finder.Result






























    properties(SetAccess=protected)



        Object=[];
    end

    properties(Access=protected,Hidden)
        Reporter=[];
    end

    properties



Name



Component



Parent



Period



ExecutionOrder




Tag
    end

    methods(Access={?mlreportgen.report.ReportForm,?systemcomposer.rptgen.finder.FunctionFinder})
        function this=FunctionResult(f)
            this@mlreportgen.finder.Result(f);
        end
    end

    methods

        function title=getDefaultSummaryTableTitle(~,varargin)
            title="";
        end



        function props=getDefaultSummaryProperties(~,varargin)
            props="";
        end




        function propVals=getPropertyValues(~,~,varargin)
            propVals={};
        end
    end

    methods
        function reporter=getReporter(this)








            if isempty(this.Reporter)
                reporter=systemcomposer.rptgen.report.Function("Source",this);
                this.Reporter=reporter;
            else
                reporter=this.Reporter;
            end
        end

        function presenter=getPresenter(this)%#ok<*MANU>
            presenter=[];
        end
    end
end