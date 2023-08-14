classdef InterfaceResult<mlreportgen.finder.Result




























    properties(SetAccess=protected)



        Object=[];
    end

    properties(Access=protected,Hidden)

        Reporter=[];
    end

    properties



InterfaceName



Elements



Ports




Tag
    end

    methods(Access={?mlreportgen.report.ReportForm,?systemcomposer.rptgen.finder.InterfaceFinder})
        function this=InterfaceResult(f)
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








            reporter=systemcomposer.rptgen.report.Interface("Source",this);
        end

        function presenter=getPresenter(this)%#ok<*MANU>
            presenter=[];
        end
    end
end