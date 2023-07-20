function jmaab_jc_0241






    checkID='jc_0241';
    checkGroup='jmaab';
    mdladvRoot=ModelAdvisor.Root;

    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0241');

    rec.Title=DAStudio.message(['ModelAdvisor:jmaab:',checkID,'_title']);
    rec.TitleTips=[DAStudio.message(['ModelAdvisor:jmaab:',checkID,'_guideline']),newline,newline,DAStudio.message(['ModelAdvisor:jmaab:',checkID,'_tip'])];
    rec.CSHParameters.MapKey=['ma.mw.',checkGroup];
    rec.CSHParameters.TopicID=['mathworks.',checkGroup,'.',checkID];
    rec.SupportLibrary=true;
    rec.SupportExclusion=false;
    rec.SupportHighlighting=false;
    rec.Value=true;

    rec.setLicense({styleguide_license});


    paramConvention=Advisor.Utils.createStandardInputParameters('jmaab.StandardSelection');
    paramMinLength=Advisor.Utils.getInputParam_String('ModelAdvisor:jmaab:MinLength',[2,2],[1,2]);
    paramMaxLength=Advisor.Utils.getInputParam_String('ModelAdvisor:jmaab:MaxLength',[2,2],[3,4]);

    [paramMinLength.Value,paramMaxLength.Value]=Advisor.Utils.Naming.getNameLength('JMAAB');
    inputParamList={paramConvention,paramMinLength,paramMaxLength};

    rec.setInputParametersLayoutGrid([2,4]);
    rec.setInputParameters(inputParamList);
    rec.setInputParametersCallbackFcn(@inputParam_CallBack);



    rec.setCallbackFcn(@checkCallBack,'None','StyleOne');

    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});
end



function[ResultDescription]=checkCallBack(system)
    ResultDescription={};
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    subtitle=DAStudio.message('ModelAdvisor:jmaab:jc_0241_subtitle');

    ft.setInformation(subtitle);
    ft.setSubBar(false);


    modelName=bdroot(system);

    [bResult,minLength,maxLength]=checkAlgo(modelName,mdlAdvObj);
    if bResult
        ft.setSubResultStatus('Warn');
        information=ModelAdvisor.Paragraph;
        information.addItem(DAStudio.message('ModelAdvisor:jmaab:jc_0241_fail'));
        information.addItem(Advisor.Utils.Simulink.getObjHyperLink(get_param(system,'object')));
        ft.setSubResultStatusText(information);
        ft.setRecAction(DAStudio.message('ModelAdvisor:jmaab:jc_0241_recAction',num2str(minLength),num2str(maxLength)));
        mdlAdvObj.setCheckResultStatus(false);
    else
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:jmaab:jc_0241_pass'));
        mdlAdvObj.setCheckResultStatus(true);
    end
    ResultDescription{end+1}=ft;
end


function[bResult,minLength,maxLength]=checkAlgo(modelName,mdlAdvObj)
    inputParams=mdlAdvObj.getInputParameters;

    minLength=str2double(inputParams{2}.Value);
    maxLength=str2double(inputParams{3}.Value);


    if~isempty(minLength)&&~isnan(minLength)&&isnumeric(minLength)
        minLength=minLength(1);
    else
        minLength=str2double(Advisor.Utils.Naming.getNameLength('JMAAB'));
    end

    if~isempty(maxLength)&&~isnan(maxLength)&&isnumeric(maxLength)
        maxLength=maxLength(1);
    else
        [~,maxLength]=Advisor.Utils.Naming.getNameLength('JMAAB');
        maxLength=str2double(maxLength);
    end

    modelNameLen=length(modelName);
    bResult=modelNameLen<minLength||modelNameLen>maxLength;

end



function inputParam_CallBack(taskobj,tag,handle)%#ok<INUSD>
    if strcmp(tag,'InputParameters_1')
        if isa(taskobj,'ModelAdvisor.Task')
            inputParameters=taskobj.Check.InputParameters;
        elseif isa(taskobj,'ModelAdvisor.ConfigUI')
            inputParameters=taskobj.InputParameters;
        else
            return
        end

        switch inputParameters{1}.Value
        case 'JMAAB'

            [inputParameters{2}.Value,...
            inputParameters{3}.Value]=Advisor.Utils.Naming.getNameLength('JMAAB');

            inputParameters{2}.Enable=false;
            inputParameters{3}.Enable=false;
        case 'Custom'
            inputParameters{2}.Enable=true;
            inputParameters{3}.Enable=true;

        otherwise

        end

    end
end
