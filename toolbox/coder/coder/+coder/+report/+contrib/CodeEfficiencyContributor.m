


classdef(Sealed)CodeEfficiencyContributor<coder.report.Contributor

    properties(Constant)
        ID='coder-codeEfficiency'
    end

    properties(Constant,Access=private)
        DATA_GROUP_OLD='codeEfficiency'
        DATA_GROUP_NEW='codeEfficiencyNew'
    end

    properties(SetAccess=private)
        Results codergui.internal.insight.CodeEfficiencyResults
    end

    methods
        function relevant=isRelevant(~,reportContext)
            relevant=isfield(reportContext.Report,'summary')&&...
            isfield(reportContext.Report.summary,'passed')&&...
            isfield(reportContext.Report.summary,'name');
        end

        function supported=isSupportsVirtualMode(~,~)
            supported=true;
        end

        function contribute(this,reportContext,contribContext)
            this.Results=codergui.internal.insight.processCodeEfficiencyResults(reportContext,...
            ContributionContext=contribContext);


            newStorage=containers.Map();
            for i=1:numel(this.Results.ActiveCategories)
                catInfo=this.Results.ActiveCategories(i);
                issueMap=this.Results.getIssueMap(catInfo);
                if catInfo.IsLegacyMode
                    contribContext.addData(this.DATA_GROUP_OLD,char(catInfo.InternalId),issueMap);
                else
                    newStorage(catInfo.InternalId)=issueMap;
                end
            end


            contribContext.addData(this.DATA_GROUP_NEW,'categories',num2cell(this.Results.ActiveCategories));
            contribContext.addData(this.DATA_GROUP_NEW,'issues',newStorage);
        end

        function riContributor=getRIContributor(this,reportContext)
            if isempty(this.Results)
                results=codergui.internal.insight.processCodeEfficiencyResults(reportContext);
            else
                results=this.Results;
            end
            riContributor=coder.reportinfo.CodeEfficiencyRIContributor(results);
        end
    end

    methods(Static,Hidden)
        function enabled=isHighlightPotentialDataTypeIssues(reportContext)
            enabled=~isempty(reportContext.Config)||~isempty(reportContext.FeatureControl);
            if~enabled
                return;
            end
            if~isempty(reportContext.Config)
                enabled=isprop(reportContext.Config,'HighlightPotentialDataTypeIssues')&&...
                reportContext.Config.HighlightPotentialDataTypeIssues;
            end
            if~enabled&&~isempty(reportContext.FeatureControl)

                enabled=reportContext.FeatureControl.HighlightPotentialDataTypeIssues;
            end
        end
    end
end