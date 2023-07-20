function recordCellArray=defineModelAdvisorCallbacks




















































































    recordCellArray={};


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleCheckSfunctions');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipCheckSfunctions');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='SFunctionValidation';
    rec.RAWTitle='For S-functions suggest turning on checking for solver consistency and array bounds';
    rec.CallbackHandle=sl('getFcnHandle','MAExecCheckSfunctionChecking');
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturninRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.SupportExclusion=true;
    rec.TitleID='mathworks.design.DiagnosticSFcn';
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.VisibleInProductList=true;

    recordCellArray{end+1}=rec;



    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleNonContSigDerivPort');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipNonContSigDerivPort');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='NonContSigDerivPort';
    rec.RAWTitle='Check for non-continuous signals driving continuous states.';
    rec.CallbackHandle=sl('getFcnHandle','MAExecCheckNonContSigToContState');
    rec.CallbackContext='PostCompile';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturninRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.TitleID='mathworks.design.NonContSigDerivPort';
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.SupportExclusion=true;
    rec.VisibleInProductList=true;

    recordCellArray{end+1}=rec;




    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleDataStoreRWOrder');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipDataStoreRWOrder');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='DSMReadWriteOrderCheck';
    rec.RAWTitle='Make sure read/write order checking is on if there are Data Store blocks';
    rec.CallbackHandle=sl('getFcnHandle','MAExecCheckReadWriteOrderChecking');
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturninRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.TitleID='mathworks.design.DiagnosticDataStoreBlk';
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.SupportExclusion=true;
    rec.VisibleInProductList=true;

    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleNonDiscSigDataStore');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipNonDiscSigDataStore');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='ContOrZOHDSM';
    rec.RAWTitle='mark read/write blocks as modeling problems';
    rec.CallbackHandle=sl('getFcnHandle','MAExecCheckContOrZohDataStore');
    rec.CallbackContext='PostCompile';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturninRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.TitleID='mathworks.design.DataStoreBlkSampleTime';
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.SupportExclusion=true;
    rec.VisibleInProductList=true;

    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleCheckForProperDataStoreBlockUsage');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipCheckForProperDataStoreBlockUsage');
    rec.TitleInRAWFormat=false;
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='ReadWriteStaticCheckUsage';
    rec.CallbackHandle=@ExecDataStoreAnalysis;
    rec.CallbackContext='PostCompile';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.TitleID='mathworks.design.OrderingDataStoreAccess';

    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.VisibleInProductList=true;
    rec.SupportExclusion=true;

    recordCellArray{end+1}=rec;


    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('Simulink:tools:MATitleDataStoreCheck');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitletipDataStoreCheck');
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='com.mathworks.MA.CheckDataStoreProperUsage';
    rec.ActionButtonName=...
    DAStudio.message('Simulink:tools:MADataStoreCheckActionButtonName');
    rec.ActionDescription=...
    DAStudio.message('Simulink:tools:MADataStoreCheckActionDescription');
    rec.CallbackHandle=sl('getFcnHandle','MAExecCheckDataStore');
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.TitleID='mathworks.design.DataStoreMemoryBlkIssue';
    rec.SupportExclusion=true;
    rec.Group='Simulink';
    rec.GroupID='Simulink';
    rec.VisibleInProductList=true;

    recordCellArray{end+1}=rec;

end


function[ResultDescription,ResultHandles]=ExecDataStoreAnalysis(system)

    ResultDescription={};
    ResultHandles={};

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);

    try

        analysisResult=slprivate('slanalyze_datastore',system);

        passMsg=DAStudio.message('Simulink:tools:MAPassedMsg');
        descriptions=['<p /><font color="#008000">',passMsg,'</font>'];






        referenceLink=['<a href="matlab:helpview([docroot ''/mapfiles/simulink.map''],'...
        ,'''Ordering_Data'')">'...
        ,DAStudio.message('Simulink:tools:MADataStoreOrderingDataStoreAccess')...
        ,'</a>'];
        if~isempty(analysisResult.AnalysisReport)
            t=analysisResult;
            analysisResult.AnalysisName={};
            analysisResult.AnalysisReport={};
            for idx=1:length(t.AnalysisReport)
                if~isempty(mdladvObj.filterResultWithExclusion(t.AnalysisName{idx}))
                    analysisResult.AnalysisName{end+1}=t.AnalysisName{idx};
                    analysisResult.AnalysisReport{end+1}=t.AnalysisReport{idx};
                end
            end
        end

        if isempty(analysisResult.AnalysisReport)

            ResultDescription{end+1}=descriptions;
            ResultHandles{end+1}=[];
            mdladvObj.setCheckResultStatus(true);
        else
            for idx=1:length(analysisResult.AnalysisReport)
                ft=ModelAdvisor.FormatTemplate('ListTemplate');
                ft.setListObj(analysisResult.AnalysisName{idx});
                ft.setSubResultStatus('warn');

                if strcmpi(analysisResult.AnalysisReport{idx},'RBW')
                    ft.setSubResultStatusText(DAStudio.message(...
                    'Simulink:tools:MADataStoreReadBeforeWriteError'));
                    ft.setSubTitle(DAStudio.message('Simulink:tools:MADataStoreRBWTitle'));
                    action=[DAStudio.message('Simulink:tools:MADataStoreRBWAction'),' '...
                    ,DAStudio.message('Simulink:tools:MADataStoreAnalysisForDetailsSee',...
                    referenceLink)];
                    ft.setRecAction(action);

                elseif strcmpi(analysisResult.AnalysisReport{idx},'WAR')
                    ft.setSubResultStatusText(DAStudio.message(...
                    'Simulink:tools:MADataStoreWriteAfterReadError'));
                    ft.setSubTitle(DAStudio.message('Simulink:tools:MADataStoreWARTitle'));
                    action=[DAStudio.message('Simulink:tools:MADataStoreWARAction'),' '...
                    ,DAStudio.message('Simulink:tools:MADataStoreAnalysisForDetailsSee',...
                    referenceLink)];
                    ft.setRecAction(action);

                else
                    ft.setSubResultStatusText(DAStudio.message(...
                    'Simulink:tools:MADataStoreMutualExclusiveness'));
                    ft.setSubTitle(DAStudio.message('Simulink:tools:MADataStoreWARTitle'));
                    action=[DAStudio.message('Simulink:tools:MADataStoreWARAction'),' '...
                    ,DAStudio.message('Simulink:tools:MADataStoreAnalysisForDetailsSee',...
                    referenceLink)];
                    ft.setRecAction(action);
                end
                mdladvObj.setCheckResultStatus(false);
                ResultDescription{end+1}=ft;%#ok<AGROW>
            end
            ResultDescription{1}.setCheckText(DAStudio.message('Simulink:tools:MATitletipCheckForProperDataStoreBlockUsage'));
            ResultDescription{end}.setSubBar(0);
        end
    catch err

        failMsg=DAStudio.message('Simulink:tools:MADataStoreAnalysisRBWError');
        errMsg=slprivate('getAllErrorIdsAndMsgs',err,...
        'concatenateIdsAndMsgs',true);
        descriptions=['<p /><font color="#800000">',failMsg,'</font>'...
        ,'<p />',strrep(errMsg,sprintf('\n'),'<br />')];

        handles=[];


        if modeladvisorprivate('muxUpgradeCheckDebugMode','get')
            for k=1:length(err.stack)
                stackDump=DAStudio.message(...
                'Simulink:tools:MAErrorStackDump',...
                err.stack(k).file,err.stack(k).line);
                descriptions=[descriptions,'<p />==&gt; ',stackDump];%#ok
            end
        end

        ResultDescription{end+1}=descriptions;
        ResultHandles{end+1}=handles;
        mdladvObj.setCheckResultStatus(false);
    end
end







