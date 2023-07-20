function[result]=EfficientTunableParamExprAlgo(system,~)

    result={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);




    if strcmp(get_param(bdroot(system),'IsERTTarget'),'off')
        ft=ModelAdvisor.FormatTemplate('ListTemplate');
        ft.setSubBar(false);
        ft.setSubResultStatus('pass');
        result{end+1}=ft;
        mdladvObj.setCheckResultStatus(true);
        return
    end

    dataFile=fullfile(matlabroot,'toolbox','simulink','simulink',...
    'modeladvisor','+internalcustomization','private',...
    'efficientTunableParamExpr.xml');

    result=Advisor.authoring.CustomCheck.checkCallback(...
    system,dataFile);

end
