function[state]=checkForAnalysability(this,params,sldvopts)




















    featureStrings={'ReportApproximationIncr','ReportApproximation','UsePolyspaceInAllModes'};
    feature_flags=turnOffFeatures(featureStrings);

    oc=onCleanup(@()restoreFeatures(feature_flags));

    state=Sldv.Advisor.MdlCompState.NotAnalyzable;

    if nargin<3
        sldvopts=params.SLDVOptions;
    end


    if~this.RepresentsTopMdl
        sldvopts.DesignMinMaxConstraints='off';
    end




    try

        showUI=false;
        startCov=[];
        preExtract=[];
        customEnhancedMCDCOpts=[];
        client=Sldv.SessionClient.DVTGA;

        if~isempty(this.ExtractedModelFilePath)
            preExtract.extractH=load_system(this.ExtractedModelFilePath);
            preExtract.AtomicSubChartWithParam=this.AtomicSubChartWithParam;
        end




        sldvopts.RebuildModelRepresentation='Always';

        cmd=['sldvprivate(''sldvRunAnalysis'', this.BlockH, '...
        ,'sldvopts, showUI, startCov, preExtract, '...
        ,'customEnhancedMCDCOpts, client)'];
        [~,status,fileNames,~,errmsg]=evalc(cmd);

        if status&&~isempty(fileNames.DataFile)
            res=load(fileNames.DataFile);
            data=res.sldvData;
            goalStatus={};
            if~isempty(res.sldvData.Objectives)
                goalStatus={res.sldvData.Objectives.status};
            end

            analysisResults.sldvDatafile=fileNames.DataFile;
            analysisResults.ActualTime=data.AnalysisInformation.AnalysisTime;


            nSatisfied=sum(strcmp(goalStatus,'Satisfied'));
            nSatisfiedNoTC=sum(strcmp(goalStatus,'Satisfied - No Test Case'));
            nSatisfiedNeedsSimulation=sum(strcmp(goalStatus,'Satisfied - needs simulation'));


            nUnsatisfiable=sum(strcmp(goalStatus,'Unsatisfiable'));
            nUnsatisfiableApprox=sum(strcmp(goalStatus,'Unsatisfiable under approximation'));


            nError=sum(strcmp(goalStatus,'Produced error'));
            nDead=this.DeadLogic.Dead;


            nTotal=length(goalStatus);


            nDecided=nSatisfied+nSatisfiedNoTC+nSatisfiedNeedsSimulation+nError+max((nUnsatisfiable+nUnsatisfiableApprox),nDead);

            if nTotal==0
                errorRatio=0;
                undecidedRatio=0;
            else
                errorRatio=nError/nTotal;
                undecidedRatio=(nTotal-nDecided)/nTotal;
            end

            if nDecided==nTotal
                this.tg_complete=true;
            end

            if undecidedRatio<=params.MaxObjUndecidedRatio&&...
                errorRatio<=params.MaxObjErrorRatio

                state=Sldv.Advisor.MdlCompState.Analyzable;
            end

            analysisResults.Total=nTotal;
            analysisResults.Decided=nDecided;

            this.TestGenResults=analysisResults;


            this.calculateRecommendedOptions(sldvopts,analysisResults,state);

        else
            im=containers.Map;
            im(this.Sid)=this.formatIncompatibilityMessages(errmsg);
            this.IncompatibilityMessages=im;
            state=Sldv.Advisor.MdlCompState.NotCompatible;
        end

    catch Mex
        err.msg=Mex.message;
        err.msgid=Mex.identifier;
        err.modelitem=this.Sid;




        im=containers.Map;
        im(this.Sid)=err;
        this.IncompatibilityMessages=im;
        state=Sldv.Advisor.MdlCompState.NotExtractable;

    end
end

function restoreFeatures(feature_flags)
    for ind=1:numel(feature_flags)
        temp=feature_flags(ind);
        slavteng('feature',temp.flag,temp.value);
    end
end

function feature_flags=turnOffFeatures(flags)
    for ind=1:numel(flags)
        temp=flags{ind};
        feature_flags(ind).flag=temp;%#ok<AGROW>
        feature_flags(ind).value=slavteng('feature',temp);%#ok<AGROW>
        slavteng('feature',temp,0);
    end
end















