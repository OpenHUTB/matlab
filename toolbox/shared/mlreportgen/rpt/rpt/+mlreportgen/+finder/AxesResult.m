classdef AxesResult<mlreportgen.finder.Result





















    properties(SetAccess=protected)


        Object=[];
    end

    properties(Access=private)
        Reporter=[];
    end

    properties




        Tag;
    end

    methods(Access={?mlreportgen.finder.AxesFinder})
        function this=AxesResult(varargin)
            this=this@mlreportgen.finder.Result(varargin{:});
            mustBeNonempty(this.Object);
        end
    end

    methods
        function reporter=getReporter(this)








            if isempty(this.Reporter)
                reporter=mlreportgen.report.Axes(this.Object);
                this.Reporter=reporter;
            else
                reporter=this.Reporter;
            end
        end

        function presenter=getPresenter(this)%#ok<MANU>
            presenter=[];
        end

        function title=getDefaultSummaryTableTitle(~,varargin)






            title=string(getString(message("mlreportgen:report:SummaryTable:axes")));
        end

        function props=getDefaultSummaryProperties(~,varargin)












            props=["Title","Tag","XLim","YLim","Units"];
        end

        function propVals=getPropertyValues(this,propNames,~,~)












            nProps=numel(propNames);
            propVals=cell(1,nProps);

            for idx=1:nProps

                prop=strrep(propNames(idx)," ","");

                if isprop(this,prop)

                    val=this.(prop);
                else

                    [val,isValid]=mlreportgen.utils.internal.getAxesProperty(this.Object,prop);
                    if~isValid
                        val="N/A";
                    end
                end


                if~isempty(val)
                    val=mlreportgen.utils.toString(val);
                end
                propVals{idx}=val;
            end
        end

        function id=getReporterLinkTargetID(this)







            id=getReporterLinkTargetID@mlreportgen.finder.Result(this);
            if isempty(id)
                id=mlreportgen.report.Axes.getLinkTargetID(this.Object);
            end
        end

    end

end