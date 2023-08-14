classdef(Hidden)NullResult<mlreportgen.finder.Result





































    properties(SetAccess=protected)
        Object=[]
    end

    properties
        Tag=[]
    end

    methods
        function reporter=getReporter(~)
            reporter=mlreportgen.report.Reporter.empty();
        end

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

    methods(Hidden)
        function presenter=getPresenter(~)
            presenter=[];
        end
    end
end

