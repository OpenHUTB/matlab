classdef RequirementSetResult<mlreportgen.finder.Result




























    properties(SetAccess=protected)



        Object=[];
    end

    properties(Access=protected,Hidden)
        Reporter=[];
    end


    properties



ID



Summary



Link




Tag
    end

    methods(Access={?mlreportgen.report.ReportForm,?systemcomposer.rptgen.finder.RequirementSetFinder})
        function this=RequirementSetResult(f)
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








            obj=systemcomposer.rptgen.report.RequirementSet("Source",this);
            reporter=obj;
        end

        function presenter=getPresenter(this)%#ok<*MANU>
            presenter=[];
        end
    end
end