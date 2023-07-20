function translateAndCheckCompat(obj,isMdlRefTranslation,buildArgs)




    if nargin<3
        buildArgs=[];
    end

    if nargin<2
        isMdlRefTranslation=false;
    end

    transLog='';
    modelName=obj.mModelToCheckCompatName;
    modelH=obj.mModelToCheckCompatH;


    warningId='RTW:configSet:mayNeedNonFiniteSupport';
    warningStatus=warning('query',warningId);
    warning('off',warningId);

    testComp=obj.mTestComp;

    if~obj.mSkipTranslation||~isempty(obj.mCompatObserverModelHs)


        try
            sldvprivate('settings_handler',obj.mModelToCheckCompatH,...
            'init_analyzis',obj.mSettingsCache,obj.mTestComp);


            slavteng('addListener',obj.mModelToCheckCompatH);

            destroyRTWCGListener=onCleanup(@()set_param(obj.mModelToCheckCompatH,'RTWCGListener',[]));

            if~obj.mSkipTranslation
                obj.logAll(getString(message('Sldv:Setup:BuildingModelRepresentation')));
                testComp.profileStage('Translation');
                testComp.getMainProfileLogger().openPhase('Translation');
            end
            transLog=locTranslate(testComp,modelName,obj.mSkipTranslation,isMdlRefTranslation,buildArgs);



            if~obj.mSkipTranslation
                switch(testComp.compatStatus)
                case{'DV_COMPAT_TRANSLATION_FAILED','DV_COMPAT_TRANSFORMATION_FAILED'}
                    obj.logNewLines(getString(message('Sldv:Setup:UnexpectedInternalError')));
                    obj.logAll(transLog);
                    obj.logAll(sprintf('\n\n'));
                end
            end

            if strcmp(testComp.compatStatus,'DV_COMPAT_COMPATIBLE')
                [object,sourceVect,~,msgidVect]=sldvshareprivate('avtcgirunsupcollect','getall');
                [~,sourceDiag,~,~]=sldvshareprivate('avtcgirunsupcollect','getallDiag');

                stubbedDiag=any(strcmp(sourceDiag,'sldv_stubbed'));

                if Sldv.CompatStatus.DV_COMPAT_PARTIALLY_SUPPORTED==obj.mCompatStatus||...
                    ~isempty(object)||...
stubbedDiag



                    if isempty(testComp.stubFcnCalledSystems)

                        if stubbedDiag||(any(strcmp(sourceVect,'sldv_stubbed'))&&...
                            ~all(strcmp(msgidVect,'Sldv:Compatibility:UnsupportedBlockSFcnNIV')))
                            testComp.compatStatus='DV_COMPAT_PARTIALLY_SUPPORTED';
                            obj.mCompatStatus=Sldv.CompatStatus.DV_COMPAT_PARTIALLY_SUPPORTED;
                        end
                    else
                        stubFcnCallIncompatibility(testComp);
                        obj.mCompatStatus=Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE;
                        testComp.compatStatus=obj.mCompatStatus.char;
                    end
                end
            else
                obj.mCompatStatus=Sldv.CompatStatus(testComp.compatStatus);
                if strcmp(testComp.compatStatus,'DV_COMPAT_UNKNOWN')
                    obj.mCompatStatus=Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE;
                    testComp.compatStatus=obj.mCompatStatus.char;
                end
            end
            if~obj.mSkipTranslation
                testComp.profileStage('end');
                testComp.getMainProfileLogger().closePhase('Translation');
            end
        catch Mex
            err=Mex;
            obj.mCompatStatus=Sldv.CompatStatus(testComp.compatStatus);
            compatStatusStr=obj.mCompatStatus.char;
            obj.logNewLines(obj.html_red(getString(message('Sldv:Setup:ErrorsDuringModelRepresentationBuild'))));
            if strcmp(compatStatusStr,'DV_COMPAT_UNKNOWN')||...
                strcmp(compatStatusStr,'DV_COMPAT_COMPATIBLE')||...
                strcmp(compatStatusStr,'DV_COMPAT_PARTIALLY_SUPPORTED')
                obj.mCompatStatus=Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE;
            end

            isCustomBlockError=comingFromCustomBlock(err);
            if isCustomBlockError
                if strcmp(Mex.identifier,'Simulink:blocks:ImplicitIterSS_NonReusableSFcn')






                    splitMsg=regexp(Mex.message,'''','split');
                    pathToAvtFcn=regexp(splitMsg{3},'/viewdvc','split');
                    objectiveBlk=pathToAvtFcn{1};

                    id='Sldv:Compatibility:ObjectiveInForEach';
                    transLog=getString(message(id,objectiveBlk));
                    mExceptionCauseFlat=sldvshareprivate('util_get_error_causes',Mex);

                    sldvshareprivate('util_add_error_causes',modelH,mExceptionCauseFlat);
                    sldvshareprivate('avtcgirunsupcollect','push',modelH,'simulink',...
                    sprintf('%s',getString(message('Sldv:Setup:BuildingModelRepresentationFailed',transLog))),id);
                end
            elseif Sldv.utils.errMsgHandler.isInvalidParamTuningError(Mex)
                [prmMsg,id]=Sldv.utils.errMsgHandler.getInvalidParamTuningError(Mex);
                sldvshareprivate('avtcgirunsupcollect','push',modelH,'simulink',prmMsg,id);
            elseif strcmp(Mex.identifier,'RTW:codeGen:sharedUtilitiesNamingClash')
                id='Sldv:Compatibility:sharedUtilitiesNamingClash';
                mesg=strtrim(extractAfter(Mex.message,':'));
                sldvshareprivate('avtcgirunsupcollect','push',modelH,'simulink',mesg,id);
            else
                if isempty(transLog)


                    if strcmp(Mex.identifier,'Simulink:DataType:RTWOverFlowDetected')


                        splitMsg=regexp(Mex.message,getString(message('Sldv:Setup:CanSuppress')),'split');
                        transLog=splitMsg{1};
                    else
                        transLog=Mex.message;
                    end
                    transLog=strrep(transLog,[getString(message('Sldv:Setup:xlate_ErrorUsing')),getString(message('Sldv:Setup:xlate_Rtwgen'))],'');
                    transLog=strrep(transLog,'$PRODUCT$','Simulink Design Verifier');
                    id=Mex.identifier;
                    mExceptionCauseFlat=sldvshareprivate('util_get_error_causes',Mex);
                    [mExceptionCauseFlat,transLog,id]=addExceptionIfMultiTasking(mExceptionCauseFlat,transLog,id,obj.mSettingsCache.params);
                else


                    id='Sldv:Compatibility:Translation';
                    mExceptionCauseFlat={};
                end
                sldvshareprivate('util_add_error_causes',modelH,mExceptionCauseFlat);
                sldvshareprivate('avtcgirunsupcollect','push',modelH,'simulink',...
                sprintf('%s',getString(message('Sldv:Setup:BuildingModelRepresentationFailed',transLog))),id);
            end

            if~obj.mSkipTranslation
                if obj.mShowUI
                    obj.logAll(getString(message('Sldv:Setup:ReferDiagnosticsWindow')));
                else
                    obj.logAll(sprintf('\n%s',transLog));
                end
            end
        end
    end

    warning(warningStatus.state,warningId);
end


function stubFcnCallIncompatibility(testcomp)
    allFcnCallErrorSys=testcomp.stubFcnCalledSystems;
    errID='Sldv:Compatibility:SysWithStubbedCaller';

    for blkH=allFcnCallErrorSys
        errMsg=getString(message(errID));
        sldvshareprivate('avtcgirunsupcollect','push',blkH,'simulink',errMsg,errID);

    end
end


function out=comingFromCustomBlock(transErrStruct)
    out=~isempty(strfind(transErrStruct.message,'customAVTBlockSFcn'));
end

function transLog=locTranslate(testComp,modelName,skipDesignModelTranslation,isMdlRefTranslation,buildArgs)%#ok<INUSD> 
    transLog='';
    testComp.reset;
    try
        wasSLDV=get_param(modelName,'InSLDVAnalysis');
        resetWasSLDV=onCleanup(@()set_param(modelName,'InSLDVAnalysis',wasSLDV));
        set_param(modelName,'InSLDVAnalysis','on');



        initialBdroot=bdroot;
        set_param(0,'CurrentSystem',modelName);
        resetBdroot=onCleanup(@()set_param(0,'CurrentSystem',initialBdroot));

        if~skipDesignModelTranslation
            sldvOutputDir=sldvprivate('mdl_get_output_dir',testComp);
            translateCmd=sprintf('rtwgen(''%s'', ''OutputDirectory'', sldvOutputDir)',modelName);
            termCmd=sprintf('rtwgen(''%s'', ''TerminateCompile'', ''on'')',modelName);
            if isMdlRefTranslation
                mdlRefTargetType=get_param(modelName,'ModelReferenceTargetType');
                resetMdlRefTargetType=onCleanup(@()set_param(modelName,'ModelReferenceTargetType',mdlRefTargetType));
                set_param(modelName,'ModelReferenceTargetType','RTW');

                translateCmd=sprintf('rtwgen(''%s'', ''OutputDirectory'', sldvOutputDir, ''MdlRefBuildArgs'', buildArgs)',modelName);
            end
            if testComp.analysisInfo.testMode||(slavteng('feature','debugLevel')>0)
                transLog=evalc(translateCmd);
                transLog1=evalc(termCmd);%#ok<NASGU>   g1594576
            else
                transLog=evalc(translateCmd);



                sldvshareprivate('avtcgirunsupcollect','removeWithMessage',[],[],[],'Simulink:Engine:WarnAlgLoopsFound');
                transLog1=evalc(termCmd);%#ok<NASGU>   g1594576
            end
        elseif~isMdlRefTranslation









            modelH=get_param(modelName,'Handle');
            assert(~isempty(Simulink.observer.internal.getObserverRefBlocksInBD(modelH)),...
            'Model must have Observers');

            compileCmd=sprintf('%s([],[],[],''compileForRTW'')',modelName);%#ok<NASGU>
            transLog=evalc('evalin(''base'',compileCmd)');
            sldvshareprivate('avtcgirunsupcollect','removeWithMessage',[],[],[],'Simulink:Engine:WarnAlgLoopsFound');
            termCmd=sprintf('%s([],[],[],''term'')',modelName);%#ok<NASGU>
            transLog1=evalc('evalin(''base'',termCmd)');%#ok<NASGU>
        end
        rtwprivate('destroyRTWContext',modelName);
    catch Mex
        rtwprivate('destroyRTWContext',modelName);



        sldvshareprivate('avtcgirunsupcollect','removeWithMessage',[],[],[],'Simulink:Engine:WarnAlgLoopsFound');
        rethrow(Mex);
    end
end


function hasMultiTasking=checkForMultiTasking(paramsCache)




    hasMultiTasking=false;

    isSolverModeModified=false;
    isAutoInsertRTModified=false;
    isSTRateTransMsgModified=false;
    for idx=1:length(paramsCache)
        paramName=paramsCache{idx}{1};
        if strcmp(paramName,'SolverMode')
            isSolverModeModified=true;
        end
        if strcmp(paramName,'AutoInsertRateTranBlk')
            isAutoInsertRTModified=true;
        end
        if strcmp(paramName,'SingleTaskRateTransMsg')
            isSTRateTransMsgModified=true;
        end
    end

    if isSolverModeModified&&isAutoInsertRTModified&&isSTRateTransMsgModified
        hasMultiTasking=true;
    end
end


function[exceptions,newMsg,newId]=addExceptionIfMultiTasking(exceptions,msgToAdd,idToAdd,paramsCache)
    newMsg=msgToAdd;
    newId=idToAdd;


    hasMultiTasking=checkForMultiTasking(paramsCache);
    if hasMultiTasking

        allCauses=cell(1,length(exceptions));
        for idx=1:length(exceptions)
            allCauses{idx}=exceptions{idx}.message;
        end






        rateTransMsg=getString(message('Simulink:blocks:HiddenBlockRelatedError','RateTransition'));
        if contains(msgToAdd,rateTransMsg)||any(contains(allCauses,rateTransMsg))
            newExc=MException(idToAdd,msgToAdd);
            exceptions=[{newExc},exceptions(:)];
            newId='Sldv:Compatibility:UnsupportedMultiTaskingToSingleTasking';
            newMsg=getString(message(newId));
        end
    end
end
