classdef(Sealed)CodeEfficiencySubCategory<codergui.internal.insight.CodeEfficiencyCategoryChild



    properties

        SubCategoryId string{mustBeTextScalar(SubCategoryId)}=""

        Title string{mustBeTextScalar(Title)}=""

        Description string{mustBeTextScalar(Description)}=""

        IssueTypes(1,:)codergui.internal.insight.CodeEfficiencyIssueType
    end
end