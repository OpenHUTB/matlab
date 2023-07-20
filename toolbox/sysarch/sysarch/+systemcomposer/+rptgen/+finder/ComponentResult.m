classdef ComponentResult<mlreportgen.finder.Result
































    properties(SetAccess=protected)



        Object=[];
    end

    properties(Access=protected,Hidden)
        Reporter=[];
    end

    properties



Name



Parent



Description



Children



Ports



ReferenceName



Kind




Tag
    end

    properties(Access={?systemcomposer.rptgen.finder.ComponentFinder,?systemcomposer.rptgen.report.Component})
Interfaces
ModelName
FullName
    end

    methods(Access={?mlreportgen.report.ReportForm,?systemcomposer.rptgen.finder.ComponentFinder})
        function this=ComponentResult(f)
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








            obj=systemcomposer.rptgen.report.Component("Source",this);
            reporter=obj;
        end

        function presenter=getPresenter(this)%#ok<*MANU>
            presenter=[];
        end
    end
end