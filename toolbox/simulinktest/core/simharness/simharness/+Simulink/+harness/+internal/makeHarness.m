function[harnessH,sigbH,testSubsysH]=makeHarness(objH,harnessName,harnessPath,DVData)





    featureOn=slfeature('UnifiedMakeHarness')>0;
    assert(featureOn,'UnifiedMakeHarness feature should be on when calling makeHarness');

    modelH=get_param(objH,'Handle');
    origDirty=get_param(modelH,'Dirty');
    oc1=onCleanup(@()set_param(modelH,'Dirty',origDirty));
    wstate=warning;
    warning('off','Simulink:Harness:ExportDeleteHarnessFromSystemModel');
    warning('off','Simulink:Harness:HarnessDeletedIndependentHarness');
    warning('off','Simulink:Harness:IndHarnessDetachWarning');
    oc2=onCleanup(@()warning(wstate));
    origMode=slsvTestingHook('UnifiedHarnessBackendMode',1);
    modeCleanup=onCleanup(@()slsvTestingHook('UnifiedHarnessBackendMode',origMode));



    sldvData=DVData.sldvData;
    extractedModel='';

    srcType='Signal Builder';
    if slfeature('UnifiedMakeHarness')&&...
        isfield(DVData.harnessOpts,'harnessSource')
        srcType=DVData.harnessOpts.harnessSource;
    end

    set_param(modelH,'Dirty','off');
    modelName=get_param(modelH,'Name');
    fileName='';
    if Simulink.harness.internal.isSavedIndependently(modelName)



        fileName=harnessPath;
    end




    sldvshareprivate('create_sltest_harness_using_sldvdata',sldvData,modelName,modelName,harnessName,...
    srcType,extractedModel,fileName,DVData.modelRefHarness);



    set_param(modelH,'Dirty','off');
    if~isempty(fileName)||isempty(harnessPath)
        Simulink.harness.internal.export(modelH,harnessName,false);
    else
        Simulink.harness.internal.export(modelH,harnessName,false,'Name',harnessPath);
    end

    harnessH=get_param(harnessName,'Handle');

    [sigbH,testSubsysH]=postProcessForMakeHarness(modelH,harnessH,DVData,harnessPath);



    set_param(modelH,'Dirty','off');
    save_system(harnessH);

end








function[sigbH,testSubsysH]=postProcessForMakeHarness(modelH,harnessH,DVData,harnessPath)

    modelRefHarness=DVData.modelRefHarness;
    harnessOpts=DVData.harnessOpts;
    sldvData=DVData.sldvData;
    harnessFromMdl=DVData.harnessFromMdl;




    param1Name='TestUnitModel';
    param1Value=get_param(modelH,'Name');

    modelParam=sprintf('%s=%s|',param1Name,param1Value);
    try
        set_param(harnessH,'SldvGeneratedHarnessModel',modelParam);
    catch
        add_param(harnessH,'SldvGeneratedHarnessModel',modelParam);
    end


    fontName=get_param(modelH,'DefaultBlockFontName');
    set_param(harnessH,'DefaultBlockFontName',fontName);

    sigbH=[];


    sigBuilder=find_system(harnessH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Name','Harness Inputs');
    if~isempty(sigBuilder)
        sigbH=get_param(sigBuilder,'Handle');

        set_param(sigbH,'Name','Inputs');
    end

    testunitName=getfullname(modelH);
    if modelRefHarness
        unitName='Test Unit';
    else
        unitName=['Test Unit (copied from ',testunitName,')'];
    end

    testSubsysName=[get_param(harnessH,'Name'),'/',unitName];


    cutBlock=find_system(harnessH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'SID','1');

    if~modelRefHarness
        pos=get_param(cutBlock,'Position');
        replace_block(harnessH,'SID','1','built-in/SubSystem','KeepSID');


        cutBlock=find_system(harnessH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'SID','1');
        set_param(cutBlock,'Name',unitName);
        testSubsysH=get_param(testSubsysName,'Handle');
        feval('Simulink.BlockDiagram.copyContentsToSubSystem',modelH,testSubsysH);
        set_param(testSubsysH,'Position',pos);
        set_param(testSubsysH,'Permissions','ReadOnly');



        modelWorkspaceUtils=feval('Simulink.ModelReference.Conversion.ModelWorkspaceUtils',modelH,harnessH);
        modelWorkspaceUtils.copy;
        set_param(harnessH,'covModelRefEnable','off');
...
...
...
...
...
...
...
        set_param(harnessH,'CovScope','Subsystem');
        idx=strfind(testSubsysName,'/');
        testSubsysNameRelative=testSubsysName(idx(1):end);
        set_param(harnessH,'CovPath',testSubsysNameRelative);
    else
        set_param(cutBlock,'Name',unitName);
        testSubsysH=cutBlock;
    end

    if strcmpi(sldvData.AnalysisInformation.Options.CovFilter,'on')
        if isfield(sldvData.ModelInformation,'ExtractedModel')&&~isempty(sldvData.ModelInformation.ExtractedModel)
            CovFilterFile=get_param(modelH,'DVCovFilterFileName');
        else
            CovFilterFile=sldvData.AnalysisInformation.Options.CovFilterFileName;
        end
        if~isempty(CovFilterFile)
            if~modelRefHarness
                newFilterFileName=SlCov.FilterEditor.convertCovFilter(CovFilterFile,...
                modelH,testSubsysH,'_covfilter',...
                fileparts(harnessPath));
            else
                newFilterFileName=CovFilterFile;
            end
            set_param(harnessH,'CovFilter',newFilterFileName);
        end
    end



    if harnessFromMdl
        set_param(harnessH,'StopTime',get_param(modelH,'StopTime'));
    end
end


