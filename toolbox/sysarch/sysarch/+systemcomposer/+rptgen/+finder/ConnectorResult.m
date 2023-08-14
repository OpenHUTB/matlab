classdef ConnectorResult<mlreportgen.finder.Result
































    properties(SetAccess=protected)



        Object=[];
    end

    properties(Access=protected,Hidden)
        Reporter=[];
    end

    properties



Name



SourcePort



DestinationPort



Parent



Stereotypes




Tag
    end

    methods(Access={?mlreportgen.report.ReportForm,?systemcomposer.rptgen.finder.ConnectorFinder})
        function this=ConnectorResult(f)
            this@mlreportgen.finder.Result(f);
        end
    end

    methods

        title=getDefaultSummaryTableTitle(~,varargin)



        props=getDefaultSummaryProperties(~,varargin)




        propVals=getPropertyValues(~,~,varargin)
    end

    methods
        function reporter=getReporter(this)








            if isempty(this.Reporter)
                reporter=systemcomposer.rptgen.report.Connector("Source",this);
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