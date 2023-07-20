function[harnessFilePath,warnmsg]=make_model_harness(model,sldvData,harnessOpts,utilityName,maxConstHandle)





    if ischar(model)||isstring(model)
        [~,model]=fileparts(model);
        try
            if~bdIsLoaded(model)
                load_system(model);
            end
            modelH=get_param(model,'Handle');
        catch Mex
            error('Sldv:MAKEHARNESS:InvalidInput',model);
        end
    else
        if ishandle(model)
            modelH=model;
        else
            error('Sldv:MAKEHARNESS:InvalidInput','');
        end
    end


    if Sldv.xform.MdlInfo.isMdlCompiled(model)
        error(message(...
        'Sldv:HarnessUtils:MakeSystemTestHarness:FailedHarnessInCompiledMode'));
    end
    warnmsg={};



    harnessFromMdl=false;




    appendDataExistHarness=false;



    extraHarnessOpts=Sldv.HarnessUtils.getExtraHarnessOpts;
    if~isfield(harnessOpts,'createReshapeOutputsSubsystem')
        harnessOpts.createReshapeOutputsSubsystem=extraHarnessOpts.createReshapeOutputsSubsystem;
    end





    if~slavteng('feature','ExportToTestSequence')&&...
        strcmp(harnessOpts.harnessSource,'Test Sequence')
        harnessOpts.harnessSource='Signal Editor';
    end

    if~isfield(harnessOpts,'useUnderscores')
        harnessOpts.useUnderscores=extraHarnessOpts.useUnderscores;
    end
    if~isfield(harnessOpts,'logInputsAndOutputs')
        harnessOpts.logInputsAndOutputs=extraHarnessOpts.logInputsAndOutputs;
    end
    if~isfield(harnessOpts,'noDocBlock')
        harnessOpts.noDocBlock=extraHarnessOpts.noDocBlock;
    end
    if~isfield(harnessOpts,'visible')
        harnessOpts.visible=extraHarnessOpts.visible;
    end
    if~isfield(harnessOpts,'ignoreEmptyData')
        harnessOpts.ignoreEmptyData=extraHarnessOpts.ignoreEmptyData;
    end
    if~isfield(harnessOpts,'xilModelWrapperOnly')
        harnessOpts.xilModelWrapperOnly=extraHarnessOpts.xilModelWrapperOnly;
    end


    if harnessOpts.xilModelWrapperOnly
        harnessOpts.harnessSource='Signal Editor';
        harnessOpts.modelRefHarness=true;
    end


    if nargin<5
        maxConstHandle=[];
    end

    if(strcmp(utilityName,'sldvmakeharness'))
        invalid=builtin('_license_checkout','Simulink_Design_Verifier','quiet');
        if invalid
            error(message('Sldv:MAKEHARNESS:DisabledSldvLic'));
        end
        mode='Sldv';
    elseif(strcmp(utilityName,'slvnvmakeharness'))
        mode='Slvnv';
        invalid=~SlCov.CoverageAPI.checkCvLicense();
        if invalid
            error(message('Sldv:MAKEHARNESS:DisabledCoverageLic'));
        end
    elseif(strcmp(utilityName,'stmmakeharness'))
        mode='STM';
    elseif(strcmp(utilityName,'slicemakeharness'))

        mode='Sldv';
        invalid=~SliceUtils.isSlicerAvailable();
        if invalid

            error(message('Sldv:MAKEHARNESS:DisabledSldvLic'));
        end
    else
        error(message('Sldv:MAKEHARNESS:Unrecognized'));
    end


    if strcmp(get_param(modelH,'isHarness'),'on')
        error(message('Sldv:MAKEHARNESS:TestHarness'));
    end


    modelObj=get_param(modelH,'Object');
    if~modelObj.isa('Simulink.BlockDiagram')||strcmp(modelObj.BlockDiagramType,'library')
        error(message('Sldv:MAKEHARNESS:DisabledLib'));
    end




    hasMissingSLFunctions=sldvshareprivate('mdl_has_missing_slfunction_defs',modelH);



    if~isempty(sldvData)&&...
        (strcmp(get_param(modelH,'IsExportFunctionModel'),'on')||hasMissingSLFunctions)
        modelH=sldvprivate('getExtractedMdl',sldvData,modelH);
    end








    if isempty(sldvData)&&hasMissingSLFunctions
        error(message('Sldv:MAKEHARNESS:MissingSLFunctions'));
    end

    if~slavteng('feature','BusElemPortSupport')&&sldvshareprivate('mdl_check_rootlvl_buselemport',modelH)
        error(message('Sldv:MAKEHARNESS:RootLvlBusElemPortNotSupported'));
    end

    [inBlks,~,mTriggerBlkHs,mEnableBlkHs,mFcnCallInHs]=Sldv.utils.getSubSystemPortBlks(modelH);
    if~isempty(mTriggerBlkHs)||~isempty(mEnableBlkHs)
        error(message('Sldv:MAKEHARNESS:EnableTriggerPort'));
    end

    if~isempty(mFcnCallInHs)
        error(message('Sldv:MAKEHARNESS:FunctionCallInPorts'));
    end

    if isempty(inBlks)&&is_sldv_harness(modelH)
        [harnessSource,errMsg]=Sldv.harnesssource.Source.getSource(modelH);
        if~isempty(errMsg)
            error(errMsg);
        else

            existHarnMdlH=modelH;
            harnessFilePath=get_param(modelH,'FileName');


            harnessOpts.harnessFilePath=harnessFilePath;
            modelH=[];
            if isempty(sldvData)

                return;
            end
        end
        appendDataExistHarness=true;
    else
        existHarnMdlH=[];
        harnessSource=[];
    end

    if harnessOpts.usedSignalsOnly&&...
        strcmp(utilityName,'slvnvmakeharness')&&...
        ~(exist('slavteng','builtin')==5&&...
        exist('sldvprivate','file')==2&&...
        ~builtin('_license_checkout','Simulink_Design_Verifier','quiet'))

        warnmsg{end+1}=message('Sldv:MAKEHARNESS:DetectUnusedOff');
        harnessOpts.usedSignalsOnly=false;
    end

    if isempty(sldvData)
        sldvData=Sldv.DataUtils.generateDataFromMdl(modelH,harnessOpts.usedSignalsOnly,harnessOpts.modelRefHarness);
        harnessFromMdl=true;
    end

    [errStr,sldvData,~,isLoggedSldvData,isDerivedSldvData]=...
    Sldv.HarnessUtils.check_harness_data(modelH,sldvData,harnessOpts);
    if~isempty(errStr)
        error(errStr);
    end

    if~appendDataExistHarness
        portnames=Sldv.DataUtils.hasComplexTypeInports(sldvData,modelH);
        if(~isempty(portnames))
            if strcmp(harnessOpts.harnessSource,'Signal Builder')
                warnmsg{end+1}=message('Sldv:MAKEHARNESS:HarnessSourceChange',get_param(modelH,'Name'));
                harnessOpts.harnessSource='Signal Editor';
            end
        end
    end

    if isLoggedSldvData||isDerivedSldvData
        if harnessOpts.usedSignalsOnly

            sldvDataWithUsed=Sldv.DataUtils.generateDataFromMdl(modelH,harnessOpts.usedSignalsOnly);
            sldvData=Sldv.DataUtils.updateInportUsage(sldvData,sldvDataWithUsed);
        end
        harnessFromMdl=true;
    end

    if(sldvData.AnalysisInformation.SampleTimes==0)
        error(message('Sldv:MAKEHARNESS:InvalidSampleTime'));
    end



    if~appendDataExistHarness&&isfield(sldvData,'ModelInformation')&&...
        ~isfield(sldvData.ModelInformation,'SubsystemPath')&&...
        ~isfield(sldvData.ModelInformation,'ExtractedModel')&&...
        (~strcmp(sldvData.ModelInformation.Name,get_param(modelH,'Name'))||...
        ~strcmp(sldvData.ModelInformation.Version,get_param(modelH,'ModelVersion')))
        warnmsg{end+1}=message('Sldv:MAKEHARNESS:NameVerMismatch');
    end

    if~appendDataExistHarness
        hasRootPorts=Sldv.HarnessUtils.has_root_level_input_ports(modelH);
        if~hasRootPorts
            error(message('Sldv:MAKEHARNESS:DisabledNoInput',get_param(modelH,'Name')));
        end
    end

    if Sldv.DataUtils.has_structTypes_interface(sldvData)
        error(message('Sldv:MAKEHARNESS:DisabledInputStruct'));
    end

    if~appendDataExistHarness
        if Sldv.HarnessUtils.has_unlicensed_stateflow(modelH)
            error(message('Sldv:MAKEHARNESS:DisabledStateflowLic'));
        end
    end




    message_object=sldvshareprivate('warn_on_precision_loss',Sldv.DataUtils.getSimData(sldvData));
    if~isempty(message_object)
        warnmsg{end+1}=message_object;
    end

    opts=sldvData.AnalysisInformation.Options;
    opts=opts.deepCopy;
    harnessFilePath=harnessOpts.harnessFilePath;


    if~appendDataExistHarness&&isempty(harnessFilePath)
        if exist('sldvprivate','file')==2
            try
                testcomp=Sldv.Token.get.getTestComponent;
            catch myException %#ok<NASGU>
                testcomp=[];
            end
        else
            testcomp=[];
        end
        if harnessFromMdl||isempty(testcomp)
            opts.OutputDir='.';
        end
        harnessFilePath=Sldv.HarnessUtils.genHarnessModelFilePath(modelH,opts,mode);
    end
    [harnessFilePath,warnmsg]=make_dv_vnv_model_harness(harnessFilePath,sldvData,...
    modelH,harnessOpts,harnessFromMdl,mode,...
    maxConstHandle,warnmsg,existHarnMdlH,harnessSource);
end

function[harnessFilePath,warnmsg]=make_dv_vnv_model_harness(harnessFilePath,...
    sldvData,...
    modelH,...
    harnessOpts,...
    harnessFromMdl,...
    mode,...
    maxConstHandle,...
    warnmsg,...
    existHarnMdlH,...
    harnessSource)

    if~isa(maxConstHandle,'function_handle')||nargin(maxConstHandle)~=0||...
        nargout(maxConstHandle)~=2
        maxConstHandle=@maxConstsForReconstruction;
    end


    if isempty(existHarnMdlH)
        [reconsParams,posShift,outputPosShift,errmsg]=Sldv.HarnessUtils.getReconstructionParams(modelH,...
        sldvData,...
        maxConstHandle);
        if isempty(reconsParams)
            error(errmsg);
        end

        modelRefHarness=harnessOpts.modelRefHarness;

        if~modelRefHarness
            exportedFcnRegisteredWithSL=false;

            try
                rt=sfroot;
                machine=rt.find('-isa','Stateflow.Machine','Name',get_param(modelH,'Name'));
                charts=machine.find('-isa','Stateflow.Chart');
                for j=1:numel(charts)
                    if charts(j).ExportChartFunctions&&charts(j).RegisterExportedFunctionsWithSimulink
                        exportedFcnRegisteredWithSL=true;
                        break;
                    end
                end
            catch myException %#ok<NASGU>
            end

            if exportedFcnRegisteredWithSL
                warnmsg{end+1}=message('Sldv:MAKEHARNESS:RefEnabledExportedFcn',get_param(modelH,'Name'));
                modelRefHarness=true;
            end
        end

        if modelRefHarness
            allowVitualBus=false;



            blocksWithUspecBus=Sldv.DataUtils.has_unspecified_bus_objects(modelH,sldvData,allowVitualBus);
            if~isempty(blocksWithUspecBus)
                for idx=1:length(blocksWithUspecBus)
                    warnmsg{end+1}=message('Sldv:MAKEHARNESS:BusObjectNeededForRootOutport',blocksWithUspecBus{idx},get_param(modelH,'Name'));%#ok<AGROW> 
                end
            end
        end
    else
        reconsParams=[];
        posShift=[];
        outputPosShift=[];
        modelRefHarness=true;
    end



    if slfeature('UnifiedMakeHarness')==0||...
        (isfield(harnessOpts,'harnessSource')&&strcmp(harnessOpts.harnessSource,'Signal Editor'))
        sldvData=Sldv.DataUtils.repeat_last_step(sldvData);
    end

    fundamentalSampleTime=sldvshareprivate('mdl_derive_sampletime_for_sldvdata',sldvData.AnalysisInformation.SampleTimes);

    [sldvData,inportUsage]=Sldv.HarnessUtils.updateInportUsage(sldvData,harnessOpts);

    [time,data,groups,tcdoc,tcdocAppendTestCases]=testCaseGen(sldvData,inportUsage,harnessOpts,existHarnMdlH);


    for i=1:numel(data)
        for j=1:length(data{i})
            if any(isinf(data{i}{j}))
                error(message('Sldv:MAKEHARNESS:InfiniteData'));
            end
        end
    end

    if(~isfield(sldvData,'Objectives')||...
        isfield(sldvData,'Objectives')&&isempty(sldvData.Objectives))



        tcdoc=getString(message('Sldv:Make_model_harness:TestCaseWithDefaultValues'));

    end

    SimData=Sldv.DataUtils.getSimData(sldvData);
    has_tunable_parameters=~isempty(SimData)&&~isempty(SimData(1).paramValues);




    isXIL=Sldv.DataUtils.isXilSldvData(sldvData);
    if isXIL
        modelRefHarness=true;
    end









    if isempty(existHarnMdlH)&&~isempty(harnessFilePath)


        refMdls=find_mdlrefs(modelH,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
        dirtyModels=[];
        for i=1:length(refMdls)
            if bdIsLoaded(refMdls{i})&&strcmp(get_param(refMdls{i},'dirty'),'on')
                if modelH==get_param(refMdls{i},'handle')&&~modelRefHarness



                    continue;
                end
                set_param(refMdls{i},'dirty','off');
                dirtyModels=[dirtyModels,get_param(refMdls{i},'handle')];%#ok<AGROW>
            end
        end
        cleanupRestoreDirtyStatus=onCleanup(@()(restoreDirtyStatus(dirtyModels)));
    end

    [harnessH,sigbH,testSubsysH]=Sldv.HarnessUtils.create_model_harness(modelH,...
    harnessFilePath,time,data,...
    groups,sldvData,modelRefHarness,...
    fundamentalSampleTime,...
    reconsParams,posShift,outputPosShift,...
    harnessFromMdl,mode,harnessOpts,...
    existHarnMdlH,harnessSource);
    hws=get_param(harnessH,'modelworkspace');
    currentHarnessSource=Sldv.harnesssource.Source.getSource(harnessH);
    [numOfExistingParameters,existingParameterValues]=getMdlWSParams(hws);

    if has_tunable_parameters



        numOfExistingTestCases=currentHarnessSource.getNumberOfTestcases...
        -length(SimData);
        if numOfExistingParameters==0&&numOfExistingTestCases>0


            missingParameters(numOfExistingTestCases).parameters=[];
            hws.assignin('SldvTestCaseParameterValues',missingParameters);
        end

        sldvshareprivate('parameters','addparamstoharness',harnessH,sldvData,modelRefHarness);

    elseif numOfExistingParameters>0



        missingParameters(length(SimData)).parameters=[];
        existingParameterValues=[existingParameterValues,missingParameters];
        hws.assignin('SldvTestCaseParameterValues',existingParameterValues);
    end

    if isempty(existHarnMdlH)

        if harnessOpts.visible
            open_system(harnessH);
        end
        if~isempty(sigbH)&&~harnessOpts.noDocBlock
            addDoc(harnessH,sigbH,testSubsysH,tcdoc);
            if~strcmp(get_param(sigbH,'MaskType'),'SignalEditor')





                open_system(sigbH);
            end
        end

        if~isempty(harnessFilePath)
            harnessPath=fileparts(harnessFilePath);
            errStr=message('Sldv:MAKEHARNESS:WriteFailure',harnessFilePath);
            if(exist(harnessPath,'dir'))
                [~,attr]=fileattrib(harnessPath);
                if(attr.UserWrite)
                    warningstatus=warning('query','Simulink:Engine:SaveWithDisabledLinks_Warning');
                    warning('off','Simulink:Engine:SaveWithDisabledLinks_Warning');



                    if strcmp(sldvData.AnalysisInformation.Options.Mode,'TestGeneration')
                        Sldv.HarnessUtils.setupMultiSimDesignStudy(harnessFilePath,currentHarnessSource);
                    end

                    save_system(harnessH,harnessFilePath);
                    warning(warningstatus.state,'Simulink:Engine:SaveWithDisabledLinks_Warning');
                    errStr=[];
                end
            end

            if~isempty(errStr)
                error(errStr);
            end
        end
    else


        newTestCnt=numel(groups);
        appendDoc(existHarnMdlH,tcdocAppendTestCases,newTestCnt,harnessSource);
        notify_harness_mdl(existHarnMdlH,getString(message('Sldv:MAKEHARNESS:AppendedTests',newTestCnt)));
        save_system(existHarnMdlH);
    end




    Sldv.utils.manageAliasTypeCache('clear');
end

function restoreDirtyStatus(dirtyModels)
    for i=1:length(dirtyModels)
        set_param(dirtyModels(i),'dirty','on');
    end
end

function notify_harness_mdl(modelH,str)
    edtrs=GLUE2.Util.findAllEditors(get_param(modelH,'Name'));
    msgId='SLDV:Harness:NewTests';
    for idx=1:numel(edtrs)
        ed=edtrs(idx);


        ed.closeNotificationByMsgID(msgId);

        ed.deliverInfoNotification(msgId,str);
    end
end



function saveData=replaceInfsForHarnessGeneration(saveData)




    oneTime=0;
    for ik=1:length(saveData)
        for kk=1:length(saveData{ik,1})
            for jk=1:length(saveData{ik,1}{kk,1})
                infiniteReplaceFlag=0;
                if(isinf(saveData{ik,1}{kk,1}(jk))&&...
                    saveData{ik,1}{kk,1}(jk)>0)
                    infiniteReplaceFlag=1;
                elseif(isinf(saveData{ik,1}{kk,1}(jk))&&...
                    saveData{ik,1}{kk,1}(jk)<0)
                    infiniteReplaceFlag=2;
                end



                if infiniteReplaceFlag>0&&oneTime==0
                    oneTime=-1;
                    warning(message('Sldv:MAKEHARNESS:InfiniteDataReplacement'));
                end

                if isa((saveData{ik,1}{kk,1}(jk)),'single')
                    if infiniteReplaceFlag==1
                        saveData{ik,1}{kk,1}(jk)=realmax('single');
                    elseif infiniteReplaceFlag==2
                        saveData{ik,1}{kk,1}(jk)=-realmax('single');
                    end
                end
                if isa((saveData{ik,1}{kk,1}(jk)),'double')
                    if infiniteReplaceFlag==1
                        saveData{ik,1}{kk,1}(jk)=realmax('double');
                    elseif infiniteReplaceFlag==2
                        saveData{ik,1}{kk,1}(jk)=-realmax('double');
                    end
                end



            end
        end
    end
end

function[time,data,groups,tcdoc,tcdocAppendTestCases]=testCaseGen(saveData,inportUsage,harnessOpts,existHarnMdlH)

    if isequal(saveData.AnalysisInformation.Options.Mode,'TestGeneration')||...
        isequal(saveData.AnalysisInformation.Options.Mode,'DesignErrorDetection')
        if~isempty(existHarnMdlH)
            groupNameBase=getString(message('Sldv:TopItOff:MissingCoverageTestCase'));
        else
            groupNameBase=getString(message('Sldv:HarnessUtils:MakeSystemTestHarness:TestCase'));
        end
    else
        groupNameBase=getString(message('Sldv:HarnessUtils:MakeSystemTestHarness:Counterexample'));
    end

    time={};
    data={};
    groups={};
    tcdoc='';
    testCases={};
    tcdocAppendTestCases={};
    SimData=Sldv.DataUtils.getSimData(saveData);
    if~isempty(SimData)
        testCases=SimData;
    end

    for tc=testCases
        [time,data,groups,tcdoc,tcdocAppendTestCases]=addTestCase(saveData,inportUsage,tc,groupNameBase,...
        time,data,groups,tcdoc,harnessOpts,existHarnMdlH,tcdocAppendTestCases);
    end
end

function[time,data,groups,tcdoc,tcdocAppendTestCases]=addTestCase(saveData,inportUsage,tc,gnb,time,data,groups,tcdoc,harnessOpts,existHarnMdlH,tcdocAppendTestCases)
    index=length(groups)+1;
    [gtime,gdata]=Sldv.HarnessUtils.harness_data(tc,inportUsage,saveData,harnessOpts);



    gdata=replaceInfsForHarnessGeneration(gdata);


    if~isempty(gdata)
        alldata=cat(1,gdata{:});
        if~isempty(gtime)&&~isempty(alldata)
            time=[time,gtime];
            data=[data,gdata];






            groups{end+1}=[gnb,' ',num2str(index)];
        end
    end
    if~isempty(existHarnMdlH)
        tcdocAppendTestCases{end+1}=Sldv.DataUtils.getTestcaseDesc(saveData,index,existHarnMdlH);
    else
        tcdoc=sprintf('%s\n\n%s',tcdoc,Sldv.DataUtils.getTestcaseDesc(saveData,index));
    end
end

function addDoc(subSysH,sigbH,testSubsysH,str)
    SLLib='simulink';
    if isempty(find_system('SearchDepth',0,'Name',SLLib))
        Sldv.load_system(SLLib);
    end
    docH=add_block('simulink/Model-Wide Utilities/DocBlock',[getfullname(subSysH),'/','Test Case Explanation']);

    set_param(docH,'ShowName','on');
    set_param(docH,'UserData',str(3:end));

    if~isempty(sigbH)
        basePos=get_param(sigbH,'position');
    else
        basePos=get_param(testSubsysH,'position');
    end

    height=40;
    offset=30;
    top=basePos(4)+offset;
    docPos=[basePos(1),top,basePos(3),top+height];

    [MaxSimulinkRectLength,~]=maxConstsForReconstruction;

    if any(docPos>MaxSimulinkRectLength)
        basePos=get_param(testSubsysH,'position');
        docPos=[basePos(3)+offset...
        ,basePos(2)...
        ,2*basePos(3)-basePos(1)+offset...
        ,basePos(2)+height];
    end

    set_param(docH,'position',docPos);
end

function appendDoc(harnessH,tcdocAppendTestCases,numTestCasesAdded,harnessSource)
    testDocBlk=[];
    docblks=find_system(harnessH,'SearchDepth',1,...
    'LookUnderMasks','all',...
    'BlockType','SubSystem',...
    'PreSaveFcn','docblock(''save_document'',gcb);');
    for i=1:length(docblks)
        if strcmp(get_param(docblks,'Name'),'Test Case Explanation')
            testDocBlk=docblks(i);
        end
    end
    if~isempty(testDocBlk)
        timestamp=datestr(now);
        header=sprintf('%s%s: %s :%s','===== ',getString(message('Sldv:TopItOff:TestCasesForMissingCov')),...
        timestamp,'=====');

        totalNumOfTestCases=harnessSource.getNumberOfTestcases;
        grpNames=harnessSource.getNamesOfTestcases;
        desc='';
        for i=1:numTestCasesAdded
            desc=sprintf('%s %s %s\n\n',desc,grpNames{totalNumOfTestCases-numTestCasesAdded+i},tcdocAppendTestCases{i});
        end

        try








            fname=docblock('getBlockFileName',testDocBlk);
            edoc=matlab.desktop.editor.openDocument(fname);
            if~isempty(edoc)
                newcontent=sprintf('\n\n%s\n%s',header,desc);
                edoc.appendText(newcontent);
                docblock('close_document',testDocBlk);
            else
                existingdata=get_param(testDocBlk,'UserData');
                if isstruct(existingdata)&&isfield(existingdata,'content')
                    content=existingdata.content;
                    newcontent=sprintf('%s\n\n%s\n%s',content,header,desc);
                    existingdata.content=newcontent;
                    set_param(testDocBlk,'UserData',existingdata);
                else
                    newcontent=sprintf('%s\n\n%s\n%s',existingdata,header,desc);
                    set_param(testDocBlk,'UserData',newcontent);
                end
            end
        catch

        end
    end

end


function[MaxSimulinkRectLength,MaxZoomScale]=maxConstsForReconstruction
    MaxSimulinkRectLength=32767;
    MaxZoomScale=2;
end

function out=is_sldv_harness(modelH)
    out=false;
    try
        p=get_param(modelH,'SldvGeneratedHarnessModel');
        out=~isempty(p);
    catch
    end
end

function[numOfExistingParameters,existingParameterValues]=getMdlWSParams(hws)
    try
        existingParameterValues=hws.evalin('SldvTestCaseParameterValues');
        numOfExistingParameters=length(existingParameterValues);
    catch Mex %#ok<NASGU
        existingParameterValues=[];
        numOfExistingParameters=0;
    end
end





