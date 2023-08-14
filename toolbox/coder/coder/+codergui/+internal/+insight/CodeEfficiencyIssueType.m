classdef(Sealed)CodeEfficiencyIssueType<codergui.internal.insight.CodeEfficiencyCategoryChild



    properties

        TypeId string{mustBeTextScalar(TypeId)}=""

        CliTextKey string{mustBeTextScalar(CliTextKey)}=""

        CliText string{mustBeTextScalar(CliText)}=""

        GuiTextKey string{mustBeTextScalar(GuiTextKey)}=""

        GuiText string{mustBeTextScalar(GuiText)}=""

        Checks(:,1)string{mustBeText(Checks)}
    end
end