

function styleguide_himl_0003()

    msgGroup='ModelAdvisor:styleguide:';

    titleTips1=DAStudio.message([msgGroup,'Himl0003_TitleTips1']);
    titleTips2=DAStudio.message([msgGroup,'Himl0003_TitleTips2']);
    titleTips3=DAStudio.message([msgGroup,'Himl0003_TitleTips3']);
    titleTips=titleTips1;
    if~isempty(titleTips2)
        titleTips=[titleTips,'<br/>',titleTips2];
    end
    if~isempty(titleTips3)
        titleTips=[titleTips,'<br/>',titleTips3];
    end

    rec=ModelAdvisor.Check('mathworks.maab.himl_0003');
    rec.Title=DAStudio.message([msgGroup,'Himl0003_Title']);
    rec.TitleTips=titleTips;
    rec.SupportExclusion=true;
    rec.Group=sg_maab_group;
    rec.LicenseName={styleguide_license};
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='himl_0003';
    rec.SupportLibrary=true;
    rec.Value=true;
    rec.setCallbackFcn(@execCheck,'none','StyleThree');
    rec.setInputParametersLayoutGrid([3,1]);



    parLoc=ModelAdvisor.InputParameter;
    parLoc.Name=DAStudio.message(...
    [msgGroup,'Himl0003_ParNameLinesOfCode']);
    parLoc.Type='String';
    parLoc.Value='60';
    parLoc.Description=DAStudio.message(...
    [msgGroup,'Himl0003_ParDescriptionLinesOfCode']);
    parLoc.setRowSpan([1,1]);
    parLoc.setColSpan([1,1]);



    parDoc=ModelAdvisor.InputParameter;
    parDoc.Name=DAStudio.message(...
    [msgGroup,'Himl0003_ParNameDensityOfComments']);
    parDoc.Type='String';
    parDoc.Value='0.2';
    parDoc.Description=DAStudio.message(...
    [msgGroup,'Himl0003_ParDescriptionDensityOfComments']);
    parDoc.setRowSpan([2,2]);
    parDoc.setColSpan([1,1]);



    parCyc=ModelAdvisor.InputParameter;
    parCyc.Name=DAStudio.message(...
    [msgGroup,'Himl0003_ParNameCyclomaticComplexity']);
    parCyc.Type='String';
    parCyc.Value='15';
    parCyc.Description=DAStudio.message(...
    [msgGroup,'Himl0003_ParDescriptionCyclomaticComplexity']);
    parCyc.setRowSpan([3,3]);
    parCyc.setColSpan([1,1]);

    rec.setInputParameters({parLoc,parDoc,parCyc});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);

end

function[resultDescription,resultHandles]=execCheck(system)

    msgGroup='ModelAdvisor:styleguide:';
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    allParameters=mdladvObj.getInputParameters();

    parameterLinesOfCode=allParameters{1};
    parameterDensityOfComments=allParameters{2};
    parameterCyclomaticComplexity=allParameters{3};

    stringValueLinesOfCode=parameterLinesOfCode.Value;
    stringValueDensityOfComments=parameterDensityOfComments.Value;
    stringValueCyclomaticComplexity=parameterCyclomaticComplexity.Value;

    valueLinesOfCode=str2double(stringValueLinesOfCode);
    valueDensityOfComments=str2double(stringValueDensityOfComments);
    valueCyclomaticComplexity=str2double(stringValueCyclomaticComplexity);

    checkParameter.linesOfCode=valueLinesOfCode;
    checkParameter.densityOfComments=valueDensityOfComments;
    checkParameter.cyclomaticComplexity=valueCyclomaticComplexity;
    checkParameter.xlateTagPrefix=msgGroup;

    [bResultStatus,resultDescription,resultHandles]=...
    ModelAdvisor.Common.modelAdvisorCheck_Mfb_LimitComplexity(...
    system,...
    checkParameter);

    mdladvObj.setCheckResultStatus(bResultStatus);

end

