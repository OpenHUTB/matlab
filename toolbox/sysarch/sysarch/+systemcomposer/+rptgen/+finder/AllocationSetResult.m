classdef AllocationSetResult<mlreportgen.finder.Result






























    properties(SetAccess=protected)

        Object=[];
    end

    properties(Access=protected,Hidden)
        Reporter=[];
    end

    properties



Name



SourceModel



TargetModel



Description



Scenarios




Tag
    end

    methods(Access={?mlreportgen.report.ReportForm,?systemcomposer.rptgen.finder.AllocationSetFinder})
        function this=AllocationSetResult(f)
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
                reporter=systemcomposer.rptgen.report.AllocationSet("Source",this);
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