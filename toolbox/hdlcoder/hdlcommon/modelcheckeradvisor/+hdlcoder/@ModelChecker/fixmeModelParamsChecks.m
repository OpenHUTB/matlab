function ResultDescription=fixmeModelParamsChecks(mdlTaskObj)







    ruleName='runModelParamsChecks';
    mdlAdvObj=mdlTaskObj.MAObj;
    partiallyQualifiedCheckName=ruleName;
    UserData=mdlAdvObj.UserData(partiallyQualifiedCheckName);
    checker=UserData{1};
    List=ModelAdvisor.List;
    List.setType('bulleted');

    paramStruct=hdlcoder.ModelChecker.hdlModelParameters;
    fields=fieldnames(paramStruct);
    modelParams={};


    for i=1:numel(fields)
        fieldName=fields(i);
        modelParams{i}=get_param(checker.m_sys,fields{i});%#ok<AGROW>
        if isempty(strfind(paramStruct.(fieldName{1}),modelParams{i}))
            set_param(checker.m_sys,fieldName{1},paramStruct.(fieldName{1}));

            text=Advisor.Utils.getHyperlinkToConfigSetParameter(checker.m_sys,fieldName{1});
            List.addItem(text);
        end
    end

    ResultDescription=[ModelAdvisor.Text('Following parameters were modified:'),List];
end