classdef(Sealed)CodeEfficiencyCategory



    properties

        InternalId string{mustBeTextScalar(InternalId)}=""

        Tag string{mustBeTextScalar(Tag)}=""

        Title string{mustBeTextScalar(Title)}=""

        Description string{mustBeTextScalar(Description)}=""

        Children(1,:)codergui.internal.insight.CodeEfficiencyCategoryChild=codergui.internal.insight.CodeEfficiencyIssueType.empty()


        EnabledCallback string{mustBeTextScalar(EnabledCallback)}=""

        ConfigFeatureFlag string{mustBeTextScalar(ConfigFeatureFlag)}=""



        IsLegacyMode(1,1)logical
    end

    properties(Dependent,SetAccess=immutable,Hidden)

        IssueTypes(1,:)codergui.internal.insight.CodeEfficiencyIssueType
    end

    methods
        function issueTypes=get.IssueTypes(this)
            if isa(this.Children,'codergui.internal.insight.CodeEfficiencyIssueType')
                issueTypes=this.Children;
            else
                issueTypes=[this.Children.IssueTypes];
            end
        end
    end
end