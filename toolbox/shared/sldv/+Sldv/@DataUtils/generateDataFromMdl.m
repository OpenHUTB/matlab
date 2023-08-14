function sldvData=generateDataFromMdl(model,usedSignalsOnly,forMdlRefHarness)




    if nargin<3
        forMdlRefHarness=false;
    end

    if nargin<2
        usedSignalsOnly=false;
    end

    if ischar(model)
        try
            modelH=get_param(model,'Handle');
        catch myException %#ok<NASGU>
            modelH=[];
        end
    else
        modelH=model;
    end

    sldvData=[];

    if usedSignalsOnly&&...
        license('test','Simulink_Design_Verifier')&&...
        exist('slavteng','builtin')==5&&...
        exist('sldvprivate','file')==2&&...
        logical(slavteng('feature','UnusedInputs'))

        origDirtyFlag=get_param(modelH,'Dirty');
        origConfigSet=getActiveConfigSet(modelH);
        Sldv.utils.replaceConfigSetRefWithCopy(modelH);

        set_param(modelH,'Dirty','off');
        modelName=get_param(modelH,'Name');

        optsModel=sldvdefaultoptions(modelH);
        opts=optsModel.deepCopy;

        if forMdlRefHarness
            opts.ModelReferenceHarness='on';
        end
        logstr=getString(message('Sldv:shared:DataUtils:DetectingUnusedRootLevelInputSignals',modelName));
        disp(logstr);
        compatmsg=[];
        try
            [~,status,compatmsg,sldvData]=...
            evalc('sldvprivate(''sldvCompatibility'',modelH,[],opts,false,[])');
        catch Mex %#ok<NASGU>
            sldvData=[];
            status=false;
        end

        Sldv.utils.restoreConfigSet(modelH,origConfigSet);
        set_param(modelH,'Dirty',origDirtyFlag);

        if~status
            msg=isRateTrasRelatedErrorMsg(compatmsg);
            if~isempty(msg)
                error(message('Sldv:DataUtils:NotCompatiblewithDV',...
                modelName,msg));
            else
                error(message('Sldv:DataUtils:IncompatibleUsedSignals',modelName));
            end
        else
            logstr=getString(message('Sldv:shared:DataUtils:DetectedUnusedSignals'));
            disp(logstr);
        end
    end

    if isempty(sldvData)


        ModelInformation.Name=get_param(modelH,'Name');
        ModelInformation.Version=get_param(modelH,'ModelVersion');
        ModelInformation.Author=get_param(modelH,'Creator');

        parameterSettings.('StrictBusMsg')=...
        struct('newvalue','ErrorLevel1','originalvalue','');
        if forMdlRefHarness
            parameterSettings.('MultiTaskRateTransMsg')=...
            struct('newvalue','error','originalvalue','');
        end

        [InputPortInfo,OutputPortInfo,flatInfo]=Sldv.DataUtils.generateIOportInfo(model,parameterSettings);
        sldvOptions=feval('sldvdefaultoptions',get_param(model,'Name'));

        AnalysisInformation.Status=[];
        AnalysisInformation.AnalysisTime=0;
        AnalysisInformation.Options=sldvOptions;
        AnalysisInformation.InputPortInfo=InputPortInfo;
        AnalysisInformation.OutputPortInfo=OutputPortInfo;

        AnalysisInformation.SampleTimes=flatInfo.SampleTimes;


        sldvData.ModelInformation=ModelInformation;
        sldvData.AnalysisInformation=AnalysisInformation;
        sldvData.Constraints=[];
        sldvData.ModelObjects=[];
        sldvData.Objectives=[];


        defaultTestCase=Sldv.DataUtils.createDefaultTC(modelH,flatInfo.InportCompInfo);
        sldvData=Sldv.DataUtils.setSimData(sldvData,[],defaultTestCase);
        sldvData=Sldv.DataUtils.compressSldvData(sldvData);


        sldvData.Version='';
    end
end

function msg=isRateTrasRelatedErrorMsg(compatmsg)
    msg='';
    if~isempty(compatmsg)




        index=strcmp({compatmsg.msgid},'Sldv:Compatibility:IllegalRateTransForModelReference');
        if any(index)
            compatmsg=compatmsg(index);
            msg=compatmsg(1).msg;
        end
    end
end
