classdef DictionaryResult<mlreportgen.finder.Result





















    properties(SetAccess=protected)



        Object=[];
    end

    properties




Type



Name



Interfaces




Tag
    end

    methods(Access={?mlreportgen.report.ReportForm,?systemcomposer.rptgen.finder.DictionaryFinder})
        function this=DictionaryResult(f)
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
            reporter=[];
        end

        function presenter=getPresenter(this)%#ok<*MANU>
            presenter=[];
        end
    end
end