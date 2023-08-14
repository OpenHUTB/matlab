function jmaab_jc_0242






    checkID='jc_0242';
    checkGroup='jmaab';
    mdladvRoot=ModelAdvisor.Root;

    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0242');

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
    paramFolderMinLen=Advisor.Utils.getInputParam_String('ModelAdvisor:jmaab:MinLength',[2,2],[1,2]);
    paramFolderMaxLen=Advisor.Utils.getInputParam_String('ModelAdvisor:jmaab:MaxLength',[2,2],[3,4]);
    paramPathMaxLen=Advisor.Utils.getInputParam_String('ModelAdvisor:jmaab:MaxPathLength',[3,3],[1,4]);
    paramProjectDir=Advisor.Utils.getInputParam_String('ModelAdvisor:jmaab:ProjectDirectory',[4,4],[1,4]);

    [paramFolderMinLen.Value,...
    paramFolderMaxLen.Value]=Advisor.Utils.Naming.getNameLength('JMAAB');

    paramPathMaxLen.Value='Disabled';
    paramProjectDir.Enable=true;

    rec.setInputParametersLayoutGrid([4,4]);
    rec.setInputParameters({paramConvention,paramFolderMinLen,paramFolderMaxLen,paramPathMaxLen,paramProjectDir});
    rec.setInputParametersCallbackFcn(@inputParam_CallBack);



    rec.setCallbackFcn(@checkCallBack,'None','StyleOne');

    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});
end



function[ResultDescription]=checkCallBack(system)
    ResultDescription={};
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setSubBar(false);


    modelFileName=get_param(bdroot(system),'FileName');

    information=ModelAdvisor.Paragraph;
    information.addItem(DAStudio.message('ModelAdvisor:jmaab:jc_0242_info'));
    information.addItem(Advisor.Utils.Simulink.getObjHyperLink(get_param(system,'object')));
    ft.setInformation(information);

    [bPath,FailingNames,minLength,maxLength,maxPathLength]=checkAlgo(modelFileName,mdlAdvObj);

    if~bPath&&isempty(FailingNames)
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:jmaab:jc_0242_pass'));
        mdlAdvObj.setCheckResultStatus(true);
    end

    ResultDescription{end+1}=ft;

    if~isempty(FailingNames)
        ft1=ModelAdvisor.FormatTemplate('ListTemplate');
        ft.setSubResultStatus('Warn');
        ft1.setSubResultStatusText(DAStudio.message('ModelAdvisor:jmaab:jc_0242_fail'));
        ft1.setListObj(FailingNames);
        ft1.setSubBar(false);
        ft1.setRecAction(DAStudio.message('ModelAdvisor:jmaab:jc_0242_recAction',num2str(minLength),num2str(maxLength)));

        if bPath
            ft1.setSubBar(true);
        end

        mdlAdvObj.setCheckResultStatus(false);
        ResultDescription{end+1}=ft1;
    end

    if bPath
        ft2=ModelAdvisor.FormatTemplate('ListTemplate');
        ft2.setSubTitle(DAStudio.message('ModelAdvisor:jmaab:jc_0242_subtitle'));
        ft.setSubResultStatus('Warn');
        ft2.setSubResultStatusText(DAStudio.message('ModelAdvisor:jmaab:jc_0242_fail_path'));
        ft2.setRecAction(DAStudio.message('ModelAdvisor:jmaab:jc_0242_recAction_overallPath',num2str(maxPathLength)));
        ft2.setSubBar(false);
        mdlAdvObj.setCheckResultStatus(false);
        ResultDescription{end+1}=ft2;
    else

    end

end


function[bPath,FailingNames,minLength,maxLength,maxPathLength]=checkAlgo(modelFileName,mdlAdvObj)

    FailingNames=[];
    bPath=false;

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


    maxPathLength=inputParams{4}.Value;

    if~isequal(maxPathLength,'Disabled')
        maxPathLength=str2double(maxPathLength);
        if~isempty(maxPathLength)&&~isnan(maxPathLength)&&isnumeric(maxPathLength)
            maxPathLength=maxPathLength(1);
        else
            maxPathLength=260;
        end


        overallLength=length(modelFileName);
        bPath=overallLength>maxPathLength;
    end


    projDir=inputParams{5}.Value;
    modelFileName=fileparts(modelFileName);

    [startIndex,endIndex]=regexp(modelFileName,projDir);
    if~isempty(startIndex)&&startIndex(1)==1
        modelFileName=modelFileName(endIndex+1:end);
    end

    if isempty(modelFileName)
        return;
    end


    folderNames=strsplit(modelFileName,filesep);
    if isempty(folderNames{1})||contains(folderNames{1},':')
        folderNames=folderNames(2:end);
    end

    FailingNames=folderNames(cellfun(@(x)length(x)<minLength||length(x)>maxLength,folderNames));

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
            inputParameters{4}.Value='Disabled';

            inputParameters{2}.Enable=false;
            inputParameters{3}.Enable=false;
            inputParameters{4}.Enable=false;

        case 'Custom'
            inputParameters{2}.Enable=true;
            inputParameters{3}.Enable=true;
            inputParameters{4}.Enable=true;
            inputParameters{4}.Value='260';

        otherwise

        end

    end
end
