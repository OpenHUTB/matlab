function[analysisOk,analysisArray,analysisCount]=modelAnalysis(modelName,opts,varargin)















    if~bdIsLoaded(modelName)
        load_system(modelName);
        unloadModel=onCleanup(@()bdclose(modelName));
    end

    extraArgs={};
    if nargin>=2
        if isa(opts,'Sldv.Options')
            sldvOptions=opts;
            extraArgs=varargin;
        else
            sldvOptions=sldvoptions(modelName);
            extraArgs=[opts,varargin];
        end
    else
        sldvOptions=sldvoptions(modelName);
    end

    p=inputParser;
    addOptional(p,'forceAnalysis',false);
    addOptional(p,'testComponent',[]);

    addOptional(p,'compileModel',true);

    parse(p,extraArgs{:});

    options=p.Results;

    options=sldv.code.internal.getAnalysisOptionsFromSldv(sldvOptions,options);

    analysisMode=sldv.code.sfcn.SFunctionAnalyzer.getAnalysisModeFromOptions(sldvOptions);

    testcomp=options.testComponent;

    if~isempty(testcomp)&&isa(testcomp,'SlAvt.TestComponent')
        designModelName=get_param(testcomp.analysisInfo.designModelH,'Name');
        showBeginEnd=false;
    else
        designModelName=modelName;
        showBeginEnd=true;
    end

    startTic=tic;

    analysisCount=0;


    if showBeginEnd
        sldv.code.internal.showMessage(testcomp,'info','sldv_sfcn:sldv_sfcn:analyzingModel',modelName);
    end
    try
        getParamValues=~strcmp(sldvOptions.Parameters,'on');

        [sfcnAnalysis,warningMessages]=sldv.code.sfcn.SFunctionAnalyzer.createFromModel(modelName,'',getParamValues,options.compileModel);
        if~strcmp(designModelName,modelName)
            sfcnAnalysis.updateModelName(designModelName);
        end
        for ii=1:numel(warningMessages)
            sldv.code.internal.showString(testcomp,'warning',warningMessages(ii).Message);
        end
    catch Me
        sldv.code.internal.showMessage(testcomp,'warning','sldv_sfcn:sldv_sfcn:analyzingModelError',Me.message);
        analysisOk=false;
        return
    end

    sfcnAnalysis.setAnalysisOptions(options);
    sfcnAnalysis.AnalysisMode=analysisMode;

    analysisOk=true;
    errorCount=0;





    sfcnAnalysis.removeUnsupported();

    if nargout>=2
        analysisArray=[];
    end

    if~sfcnAnalysis.isempty()

        loader=sldv.code.sfcn.internal.CodeInfoLoader();
        instanceDd=loader.openDb(designModelName,sldvOptions);
        instanceDd.clearOtherStaticChecksums(sfcnAnalysis);

        allFunctions=sfcnAnalysis.splitEntries();

        if strcmp(analysisMode,sldv.code.sfcn.SFunctionAnalyzer.AnalysisInstance)

            for sf=1:numel(allFunctions)
                instances=allFunctions(sf).splitInstances();
                sfunctions=allFunctions(sf).getEntriesNames();
                analyzedInstances=false(size(instances));



                sameInstanceAs=detectEquivalentInstances(instances);

                analysisOk=true;

                sfunctionName=sfunctions{1};

                sldv.code.internal.showMessage(testcomp,'info','sldv_sfcn:sldv_sfcn:startingSFunctionAnalysis',sfunctionName);



                upToDate=false(size(instances));
                for ii=1:numel(instances)
                    currentAnalysis=instances(ii);
                    upToDate(ii)=isUpToDate(currentAnalysis,instanceDd,options,sfunctionName);
                    if upToDate(ii)&&sameInstanceAs(ii)>0
                        sameIndex=sameInstanceAs(ii);
                        if~upToDate(sameIndex)

                            analyzedInstances(sameIndex)=true;

                            sameInstance=instances(sameIndex);
                            copyIRInfo(sfunctionName,sameInstance,currentAnalysis);
                            instanceDd.addAnalysis(currentAnalysis);
                        end
                    end
                end

                for ii=1:numel(instances)
                    currentAnalysis=instances(ii);
                    if~upToDate(ii)&&~analyzedInstances(ii)
                        instanceDd.clearInstances(currentAnalysis);
                        analyzedInstances(ii)=true;

                        sameIndex=sameInstanceAs(ii);
                        if sameIndex>0

                            sameInstance=instances(sameIndex);
                            copyIRInfo(sfunctionName,sameInstance,currentAnalysis);
                            instanceDd.addAnalysis(currentAnalysis);
                        else
                            currentOk=doAnalysis(currentAnalysis,instanceDd,options,testcomp);
                            errorCount=errorCount+(currentOk==false);
                            analysisCount=analysisCount+1;
                            analysisOk=analysisOk&currentOk;
                        end
                    end
                end

                if~any(analyzedInstances)
                    sldv.code.internal.showMessage(testcomp,'info','sldv_sfcn:sldv_sfcn:skippingAnalysis',sfunctionName);
                elseif nargout>=2
                    instances=instances(analyzedInstances);
                    analysisArray=[analysisArray;instances(:)];%#ok
                end
            end
        else

            analysisOk=true;
            analyzedFunctions=false(size(allFunctions));

            for ii=1:numel(allFunctions)
                currentAnalysis=allFunctions(ii);
                sfunctions=currentAnalysis.getEntriesNames();

                if~isempty(sfunctions)
                    sfunctionName=sfunctions{1};
                    sldv.code.internal.showMessage(testcomp,'info','sldv_sfcn:sldv_sfcn:startingSFunctionAnalysis',sfunctionName);

                    upToDate=isUpToDate(currentAnalysis,instanceDd,options,sfunctionName);
                    if upToDate
                        sldv.code.internal.showMessage(testcomp,'info','sldv_sfcn:sldv_sfcn:skippingAnalysis',sfunctionName);
                    else
                        analyzedFunctions(ii)=true;



                        instanceDd.clearEntries(currentAnalysis);
                        currentOk=doAnalysis(currentAnalysis,instanceDd,options,testcomp);
                        analysisCount=analysisCount+1;

                        errorCount=errorCount+(currentOk==false);
                        analysisOk=analysisOk&currentOk;
                    end
                end
            end

            if nargout>=2
                analysisArray=allFunctions(analyzedFunctions);
            end
        end
    end
    if showBeginEnd
        elapsedTime=toc(startTic);

        if errorCount==0
            sldv.code.internal.showMessage(testcomp,'info','sldv_sfcn:sldv_sfcn:analyzingModelFinished',modelName);
        else
            sldv.code.internal.showMessage(testcomp,'info','sldv_sfcn:sldv_sfcn:analyzingModelFinishedWithErrors',modelName,errorCount);
        end

        sldv.code.internal.showMessage(testcomp,'info','sldv_sfcn:sldv_sfcn:analysisTimeInfo',round(elapsedTime));
    end



    function analysisOk=doAnalysis(sfcnAnalysis,instanceDd,options,testcomp)
        try
            analysisOk=sfcnAnalysis.runSldvAnalysis(options);

            fullLog=sfcnAnalysis.getFullIrLog();
            if analysisOk
                instanceDd.addAnalysis(sfcnAnalysis);
            else
                errors=fullLog.getErrors();

                if~isempty(errors)
                    errors.showMessage(testcomp);
                else
                    sldv.code.internal.showMessage(testcomp,'error','sldv_sfcn:sldv_sfcn:analysisError');
                end

                analysisOk=false;
            end

            warnings=fullLog.getWarnings();
            if~isempty(warnings)
                warnings.showMessage(testcomp);
            end
        catch ME
            sldv.code.internal.showString(testcomp,'error',ME.message);
            analysisOk=false;
        end

        function upToDate=isUpToDate(sfcnAnalysis,instanceDd,options,sfunctionName)
            if options.forceAnalysis
                upToDate=false;
            else
                [upToDate,info]=instanceDd.hasExistingInfo(sfcnAnalysis,true,false);
                if upToDate&&info.getInstancesCount()==1


                    copyIRInfo(sfunctionName,info,sfcnAnalysis);
                end
            end





            function sameInstanceAs=detectEquivalentInstances(instanceAnalyzers)
                sameInstanceAs=zeros(size(instanceAnalyzers));
                if numel(instanceAnalyzers)>0
                    entries=instanceAnalyzers(1).getEntriesNames();
                    if numel(entries)~=1
                        return
                    end
                    entryName=entries{1};

                    for ii=1:numel(instanceAnalyzers)
                        previousIndex=ii-1;
                        currentAnalyzer=instanceAnalyzers(ii);
                        currentInstance=currentAnalyzer.getInstanceInfos(entryName);
                        if numel(currentInstance)~=1
                            return
                        end

                        for jj=1:previousIndex



                            if sameInstanceAs(jj)==0
                                jjAnalyzer=instanceAnalyzers(jj);
                                jjInstance=jjAnalyzer.getInstanceInfos(entryName);

                                if jjInstance.isEquivalentDescriptor(currentInstance)
                                    sameInstanceAs(ii)=jj;
                                    break
                                end
                            end
                        end
                    end
                end


                function copyIRInfo(sfunctionName,srcAnalyzer,dstAnalyzer)
                    srcInstances=srcAnalyzer.getInstanceInfos(sfunctionName);
                    dstInstances=dstAnalyzer.getInstanceInfos(sfunctionName);
                    if numel(srcInstances)==1&&numel(dstInstances)==1
                        dstAnalyzer.FullIR=srcAnalyzer.FullIR;
                        dstAnalyzer.FullLog=srcAnalyzer.FullLog;
                        dstInstances.IRMapping=srcInstances.IRMapping;
                    end



