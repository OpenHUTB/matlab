classdef ViewResult<mlreportgen.finder.Result

































    properties(SetAccess=protected)



        Object=[];
    end

    properties(Access=protected,Hidden)


        Reporter=[];
    end

    properties



Name



Description



Select



GroupBy



Elements



SubGroups



Snapshot



Color




Tag
    end

    methods(Access={?mlreportgen.report.ReportForm,?systemcomposer.rptgen.finder.ViewFinder})
        function this=ViewResult(f)
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








            obj=systemcomposer.rptgen.report.View("Source",this);
            reporter=obj;
        end

        function presenter=getPresenter(this)%#ok<*MANU>
            presenter=[];
        end
    end

end