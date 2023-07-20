function[status,covdata,fileNames,modelH,fullCovAlreadyAcheived]=sldvgencovImpl(obj,opts,showUI,startCov,client)






    if nargin<5
        client=Sldv.SessionClient.DVCommandLine;
    end

    if nargin<4
        startCov=[];
    end

    if(nargin<3)||isempty(showUI)
        showUI=false;
    end

    if nargin<2
        opts=[];
    end



    if~showUI
        interceptor_scope_definer=Simulink.output.registerProcessor(Simulink.output.VoidInterceptorCb());%#ok<NASGU>
    end

    [errStr,modelH,~]=cmd_resolveobj(obj);
    if~isempty(errStr)
        sldvError('Sldv:SldvRun:Obj',errStr,showUI);
        return;
    end


    if(~isempty(obj))
        sldv_run_stage=Simulink.output.Stage(message('Sldv:Sldvgencov:SLDVGENCOV_STAGE_NAME').getString(),...
        'ModelName',get_param(obj,'Name'),'UIMode',showUI);%#ok<NASGU>
    end

    summedCovdata=Sldv.CvApi.sumCvData(startCov);

    if~isempty(opts)&&~strcmp(opts.SaveDataFile,'on')
        tempOpts=opts.deepCopy;
        tempOpts.SaveDataFile='on';
        opts=tempOpts;
        if~strcmp(opts.Mode,'TestGeneration')
            msg=getString(message('Sldv:Sldvgencov:InvalidUsageOfSldvgencov'));
            error('Sldv:SldvGenCov:CheckArgOpts',msg);
        end
    end

    covdata=[];
    modelH=[];
    preExtract=[];
    customEnhancedMCDCOpts=[];
    [status,fileNames,~,~,fullCovAlreadyAcheived]=sldvRunAnalysis(obj,opts,showUI,summedCovdata,preExtract,customEnhancedMCDCOpts,client);


    if status&&~isempty(fileNames.DataFile)
        tcData=load(fileNames.DataFile);
        sldvData=tcData.sldvData;
        SimData=Sldv.DataUtils.getSimData(sldvData);
        if isempty(SimData)
            status=0;
            warning(message('Sldv:GENCOV:NoTestCase'));
            return;
        end

        if isfield(sldvData.ModelInformation,'SubsystemPath')
            [~,extractedModelName]=fileparts(sldvData.ModelInformation.ExtractedModel);
            modelToRunCoverageH=get_param(extractedModelName,'Handle');
            sspath=[extractedModelName,'/',get_param(extractedModelName,'DVExtractedSubsystem')];
            isExtractedMdl=true;
            modelH=modelToRunCoverageH;
        else
            modelToRunCoverageH=get_param(sldvData.ModelInformation.Name,'Handle');
            isExtractedMdl=false;
            sspath=modelToRunCoverageH;
        end



        cvt=sldvprivate('create_cvtest',sspath,sldvData.AnalysisInformation.Options,isExtractedMdl);
        cvt.modelRefSettings.excludedModels='';

        runOpts=sldvruntestopts;
        runOpts.coverageEnabled=true;
        runOpts.coverageSetting=cvt;

        [~,covdata]=...
        sldvruntest(modelToRunCoverageH,sldvData,runOpts);
    end
end



