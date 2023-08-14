function ResultDescription=reportInvalidInputParams(ErrorStruct)
    ResultDescription={};
    for i=1:length(ErrorStruct)
        ResultDescription{end+1}=[...
        ModelAdvisor.Text('<font color="red"><b>'),...
        ModelAdvisor.Text('Invalid input parameters'),...
        ModelAdvisor.Text('</b></font>'),...
        ModelAdvisor.LineBreak,...
        ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:InputParamError',ErrorStruct(i).InputValue,ErrorStruct(i).InputFieldName,ErrorStruct(i).ShouldBe)),...
        ModelAdvisor.LineBreak];%#ok<AGROW>
    end
end










