function codeGenHook(model,lGlobalRegistry,buildInfo)




    timerClass='codertarget.profile.Timer';
    storeDataFunctionName='store_code_profiling_data_point';
    atomicReadStoreFcnName='code_profiling_atomic_read_store';
    profilingUtilitiesFile='code_profiling_utility_functions';
    singleThreadTiming=false;

    lTimer=feval(timerClass,model);%#ok<FVAL> 

    lCodeDir=locGetSourceCodeFolder(model,buildInfo);

    try
        isESBEnabled=codertarget.utils.isESBEnabled(model);
    catch
        isESBEnabled=false;
    end

    if isESBEnabled

        if~builtin('license','checkout','SoC_Blockset')
            error(message('soc:utils:NoLicense'));
        end



        taskmgrblk=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'MaskType','Task Manager');
        if~isempty(taskmgrblk)
            taskmgrblk=taskmgrblk{1};

            mdl=soc.internal.connectivity.getModelConnectedToTaskManager(taskmgrblk);

            if isequal(get_param(mdl,'BlockType'),'ModelReference')

                refMdlName=get_param(mdl,'ModelName');

                if~isequal(get_param(refMdlName,'CodeProfilingInstrumentation'),'off')
                    error(message('soc:taskprofiler:UnsupportedCIConfiguration',refMdlName));
                end
            end
        end
    end


    if isESBEnabled
        modelName='';
    else
        modelName=model;
    end

    lTaskRegistry=coder.profile.TimeProbeComponentRegistry(...
    modelName,'',get_param(model,'TargetWordSize'),lCodeDir,[]);

    lGlobalRegistry.addRegistries({lTaskRegistry});
    lGlobalRegistry.ProfilingTimer=lTimer;
    lGlobalRegistry.TargetCollectDataFcnName=storeDataFunctionName;
    lGlobalRegistry.AtomicReadStoreFcnName=atomicReadStoreFcnName;


    targetLang=get_param(model,'TargetLang');
    if strcmp(targetLang,'C')
        srcExt='.c';
        headerExt='.h';
    else
        srcExt='.cpp';
        headerExt='.h';
    end

    lSourceFile=fullfile(lCodeDir,[profilingUtilitiesFile,srcExt]);
    lHeaderFile=fullfile(lCodeDir,[profilingUtilitiesFile,headerExt]);
    lGlobalRegistry.SourceFileTargetInterface=lSourceFile;
    lGlobalRegistry.HeaderFileTargetInterface=lHeaderFile;
    lGlobalRegistry.SingleThreadTiming=singleThreadTiming;


    ert_main_file=fullfile(lCodeDir,['ert_main',srcExt]);
    model_file=fullfile(lCodeDir,[model,srcExt]);
    srcFileForUploadFcn=ert_main_file;

    hCS=getActiveConfigSet(model);
    requireXCPSupport=coder.internal.xcp.isXCPTarget(hCS);

    if~requireXCPSupport
        instrumentationWasUpToDate=i_insert_upload_fcn(hCS,storeDataFunctionName,atomicReadStoreFcnName,lTimer,srcFileForUploadFcn,...
        profilingUtilitiesFile);
    else



        ert_main_content=fileread(ert_main_file);
        model_content=fileread(model_file);
        xcpProfilingHeaderFile='ext_mode_profiling';
        instrumentationWasUpToDate=any(strfind(ert_main_content,xcpProfilingHeaderFile))||...
        any(strfind(model_content,xcpProfilingHeaderFile));
        lAbsTime=strcmp(get_param(model,'CodeProfilingXCPUseAbsoluteTime'),'on');


        i_update_globalregistry_for_xcp(model,lGlobalRegistry,buildInfo,lAbsTime,isESBEnabled);

        i_insert_upload_fcn_xcp(model,srcFileForUploadFcn,lAbsTime,isESBEnabled,...
        lGlobalRegistry.UploadDataInRealTime,instrumentationWasUpToDate);

        i_insert_header_in_source_file(ert_main_file,xcpProfilingHeaderFile,instrumentationWasUpToDate);
        i_insert_header_in_source_file(model_file,xcpProfilingHeaderFile,instrumentationWasUpToDate);
    end

    if isequal(get_param(model,'IsERTTarget'),'on')
i_insert_task_profiling_in_sourcefile...
        (model,lTaskRegistry,lCodeDir,ert_main_file,model_file,instrumentationWasUpToDate);
    end
end



function instrumentationWasUpToDate=i_insert_upload_fcn(hCS,storeDataFunctionName,...
    atomicReadStoreFcnName,lTimer,srcFile,profilingUtilitiesFile)
    srcFileContent=fileread(srcFile);

    instrumentationWasUpToDate=...
    any(strfind(srcFileContent,profilingUtilitiesFile));
    if~instrumentationWasUpToDate
        includeLineExpr='(^\s*#include ".*?".*?$)';
        match=regexp(srcFileContent,includeLineExpr,'lineanchors');
        numIncludes=length(match);

        if i_is_streaming_diag(hCS)
            uploadDecl=i_get_upload_decl_streaming(hCS);
            uploadFcn=i_get_upload_fcn_streaming(hCS,storeDataFunctionName,atomicReadStoreFcnName,lTimer);
        else
            uploadDecl=i_get_upload_decl(hCS);
            uploadFcn=i_get_upload_fcn(hCS,storeDataFunctionName,atomicReadStoreFcnName,lTimer);
        end
        srcFileContent=regexprep(srcFileContent,['(',includeLineExpr,')'],...
        sprintf('$1\n\n%s\n%s',uploadDecl,uploadFcn),...
        'lineanchors',numIncludes);

        srcFileContent=regexprep(srcFileContent,['(',includeLineExpr,')'],...
        sprintf('#include "%s.h"\n$1',profilingUtilitiesFile),...
        'lineanchors','once');
        srcFileContent=regexprep(srcFileContent,['(',includeLineExpr,')'],...
        sprintf('#include <%s.h>\n$1','stddef'),...
        'lineanchors','once');
        fid=fopen(srcFile,'w');
        fprintf(fid,'%s',srcFileContent);
        fclose(fid);
        c_beautifier(srcFile);
    end
end



function i_insert_upload_fcn_xcp(model,srcFileForUploadFcn,lAbsTime,isESBEnabled,isUploadInRealTime,instrumentationWasUpToDate)
    hCS=getActiveConfigSet(model);
    isBaremetal=isequal(codertarget.targethardware.getTargetRTOS(hCS),'Baremetal');
    if~instrumentationWasUpToDate


        if isUploadInRealTime


            fcnToToInsert='extmodeEmptyProfilingBuffer';
            if isESBEnabled



                terminateFcnName=sprintf('%s_terminate',model);
                i_insert_fcnCall(srcFileForUploadFcn,terminateFcnName,fcnToToInsert,true);
            else





                if~lAbsTime
                    stepFcnPattern=sprintf('%s_step[0-9]*',model);
                    i_insert_fcnCall(srcFileForUploadFcn,stepFcnPattern,fcnToToInsert,true);
                end
                terminateFcnName=sprintf('%s_terminate',model);
                i_insert_fcnCall(srcFileForUploadFcn,terminateFcnName,fcnToToInsert,true);
            end

        end
    end
end



function i_insert_header_in_source_file(src_file,xcpProfilingHeaderFile,headerFilePresent)
    src_content=fileread(src_file);
    if~headerFilePresent

        includeLineExpr='(^\s*#include ".*?".*?$)';
        [~,includeEndIdx]=regexp(src_content,['(',includeLineExpr,')'],...
        'lineanchors');





        src_content=insertAfter(src_content,includeEndIdx(end),...
        sprintf('\n#include "%s.h"',xcpProfilingHeaderFile));

        fid=fopen(src_file,'w');
        fprintf(fid,'%s',src_content);
        fclose(fid);
        c_beautifier(src_file);
    end
end



function i_update_globalregistry_for_xcp(model,lGlobalRegistry,buildInfo,lAbsTime,isESBEnabled)
    hCS=getActiveConfigSet(model);
    lOperatingSystem=codertarget.targethardware.getTargetRTOS(hCS);
    isBaremetal=isequal(lOperatingSystem,'Baremetal');


    buildDir=fullfile(buildInfo.Settings.LocalAnchorDir,buildInfo.ComponentBuildFolder);

    lGlobalRegistry.RequireXCPSupport=true;
    lGlobalRegistry.XCPInstrumentedFolder=buildDir;
    lGlobalRegistry.AddXCPHeaderFiles=[];
    lGlobalRegistry.AddXCPSourceFiles=[];
    lGlobalRegistry.XCPCoreIDFcn=[];
    lGlobalRegistry.XCPThreadIDFcn=[];
    lGlobalRegistry.XCPEventID=coder.profile.xcp.profilingXCPEventID();



    lGlobalRegistry.UploadDataInRealTime=...
    ~isequal(get_param(model,'CodeProfilingSaveOptions'),'MetricsOnly');

    if isESBEnabled
        if isBaremetal

            lGlobalRegistry.InlineGeneratedCode=...
            ~strcmp(get_param(model,'TargetLangStandard'),'C89/C90 (ANSI)');
            lGlobalRegistry.SplitAtomicReadStoreFcn=true;
            lGlobalRegistry.XCPBufferConfig=...
            coder.profile.xcp.computeBufferParameters(hCS,...
            lGlobalRegistry.ProfilingTimer.getTimerType,false,false);
        else
            lGlobalRegistry.AddXCPHeaderFiles{end+1}='linuxinitialize.h';
            lGlobalRegistry.XCPThreadIDFcn='pthread_self()';
            if~lGlobalRegistry.SingleTaskModel
                th=codertarget.targethardware.getHardwareConfiguration(hCS);
                assert(~isempty(th));
                if th.NumOfCores>1
                    lGlobalRegistry.XCPCoreIDFcn='sched_getcpu()';
                end
                lGlobalRegistry.XCPNumCores=th.NumOfCores;
            end
            lGlobalRegistry.XCPBufferConfig=...
            coder.profile.xcp.computeBufferParameters(hCS,...
            lGlobalRegistry.ProfilingTimer.getTimerType,true,true);
        end
    else
        profiler=codertarget.attributes.getAttribute(model,'Profiler');
        if isstruct(profiler)&&isfield(profiler,'NumberOfBuffers')&&~isempty(profiler.NumberOfBuffers)

            if isnan(str2double(profiler.NumberOfBuffers))
                numOfProfilingBuffers=feval(profiler.NumberOfBuffers,hCS);
            else
                numOfProfilingBuffers=str2double(profiler.NumberOfBuffers);
            end
        else
            numOfProfilingBuffers=10;
        end

















        lGlobalRegistry.XCPCustomMemoryModel=true;
        lGlobalRegistry.XCPCustomMemoryNumSlabs=numOfProfilingBuffers;
        lGlobalRegistry.XCPCustomMemorySafetyHeader=25;
        lGlobalRegistry.XCPCustomMemorySafetyTrailer=5;


        if slfeature('ExtModeXCPMemoryConfiguration')



            buildInfo.addDefines(...
            {'-DXCP_MEM_BLOCK_4_NUMBER=0','-DXCP_MEM_BLOCK_4_SIZE=0'},'OPTS');
        end


        buildInfo.addDefines('-DEXTMODE_CODE_EXEC_PROFILING_CUSTOM','OPTS');








        hasFcnInstr=~isequal(get_param(model,'CodeProfilingInstrumentation'),'off');
        if hasFcnInstr||lAbsTime
            maxNumSamples=[];
        else
            maxNumSamples=4;
        end
        if isBaremetal||~strcmpi(lOperatingSystem,'Linux')
            lGlobalRegistry.InlineGeneratedCode=...
            ~strcmp(get_param(model,'TargetLangStandard'),'C89/C90 (ANSI)');
            hasCPUAndThreadId=false;
        else

            lGlobalRegistry.XCPCoreIDFcn='profiling_get_cpuid_x86()';
            lGlobalRegistry.AddXCPHeaderFiles{end+1}=fullfile(matlabroot,...
            'toolbox','coder','profile','src','host_cpuid_x86.h');
            lGlobalRegistry.AddXCPSourceFiles{end+1}=fullfile(matlabroot,...
            'toolbox','coder','profile','src','host_cpuid_x86.c');
            lGlobalRegistry.XCPThreadIDFcn='profiling_get_threadid_x86()';
            lGlobalRegistry.AddXCPHeaderFiles{end+1}=fullfile(matlabroot,...
            'toolbox','coder','profile','src','host_threadid_x86.h');
            lGlobalRegistry.AddXCPSourceFiles{end+1}=fullfile(matlabroot,...
            'toolbox','coder','profile','src','host_threadid_x86.c');
            th=codertarget.targethardware.getHardwareConfiguration(hCS);
            assert(~isempty(th));
            lGlobalRegistry.XCPNumCores=th.NumOfCores;
            hasCPUAndThreadId=true;
        end
        lGlobalRegistry.XCPBufferConfig=...
        coder.profile.xcp.computeBufferParameters(hCS,...
        lGlobalRegistry.ProfilingTimer.getTimerType,...
        hasCPUAndThreadId,hasCPUAndThreadId,maxNumSamples);
    end
end


function i_insert_task_profiling_in_sourcefile(model,lTaskRegistry,...
    codeDir,ert_main_file,model_file,...
    instrumentationWasUpToDate)
    ert_main_content=fileread(ert_main_file);
    model_content=fileread(model_file);

    [~,candidateObjFolderLastPart]=fileparts(codeDir);
    if~isequal(candidateObjFolderLastPart,'instrumented')
        codeInfoPath=fullfile(codeDir,'codeInfo.mat');
    else
        codeInfoPath=fullfile(codeDir,'..','codeInfo.mat');
    end

    codeDescriptor=coder.internal.getCodeDescriptorInternal(codeInfoPath,247362);
    codeInfo=codeDescriptor.getComponentInterface();
    codeInfoFcnMethods={...
    'InitializeFunctions',...
    'UpdateFunctions',...
    'OutputFunctions',...
    'InitConditionsFunction',...
    'TerminateFunctions',...
    };
    tid01eq=i_isTID01Equal(model,codeInfo,codeInfoFcnMethods);
    for ii1=1:length(codeInfoFcnMethods)
        fcns=codeInfo.(codeInfoFcnMethods{ii1});
        numFcns=length(fcns);
        if isequal(codeInfoFcnMethods{ii1},'OutputFunctions')&&(numFcns>1)
            for kk2=1:numFcns
                if contains(fcns(kk2).Prototype.Name,[model,'_step'])&&~isempty(fcns(kk2).ActualArgs)
                    ert_main_content=i_insert_task_profiling_for_step_fcn...
                    (model,ert_main_content,lTaskRegistry,fcns(kk2),tid01eq);
                else
                    if~isempty(strfind(ert_main_content,fcns(kk2).Prototype.Name))
                        ert_main_content=i_insert_task_profiling...
                        (model,ert_main_content,lTaskRegistry,fcns(kk2));
                    elseif~isempty(fcns(kk2).Timing)
                        model_content=i_insert_task_profiling...
                        (model,model_content,lTaskRegistry,fcns(kk2));
                    end
                end
            end
        else
            for kk2=1:numFcns
                if~isempty(strfind(ert_main_content,fcns(kk2).Prototype.Name))
                    ert_main_content=i_insert_task_profiling...
                    (model,ert_main_content,lTaskRegistry,fcns(kk2));
                else




                    if~isempty(fcns(kk2).Timing)
                        model_content=i_insert_task_profiling...
                        (model,model_content,lTaskRegistry,fcns(kk2));
                    end
                end
            end
        end
    end

    if~isequal(candidateObjFolderLastPart,'instrumented')
        dataMatfile=fullfile(codeDir,'tasks.mat');
    else
        dataMatfile=fullfile(codeDir,'..','tasks.mat');
    end
    if isequal(exist(dataMatfile,'file'),2)
        dataMat=load(dataMatfile);
        taskVec=dataMat.taskVec;
        if isfield(dataMat,'taskVec')
            for ii=1:numel(dataMat.taskVec)
                [model_content,taskVec(ii)]=i_insert_taskblock_profiling(model,model_content,lTaskRegistry,taskVec(ii));
            end
            save(dataMatfile,'taskVec');
        end
    end
    if~instrumentationWasUpToDate
        fid=fopen(ert_main_file,'w');
        fprintf(fid,'%s',ert_main_content);
        fclose(fid);
        c_beautifier(ert_main_file);
        fid=fopen(model_file,'w');
        fprintf(fid,'%s',model_content);
        fclose(fid);
        c_beautifier(model_file);
    end
end



function tid01eq=i_isTID01Equal(model,codeInfo,codeInfoFcnMethods)
    tid01eq=false;
    [found,idx]=ismember('OutputFunctions',codeInfoFcnMethods);
    if~found,return;end
    fcns=codeInfo.(codeInfoFcnMethods{idx});
    numFcns=length(fcns);
    if numFcns<=1,return;end
    tidNames={};
    for j=1:numFcns
        if contains(fcns(j).Prototype.Name,[model,'_step'])&&~isempty(fcns(j).ActualArgs)
            tidNames{end+1}=fcns(j).ActualArgs.GraphicalName;%#ok<AGROW>
        end
    end
    tid01eq=~ismember('TID1',tidNames);
end



function ret=i_is_streaming_diag(hCS)

    modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance(hCS.getModel);
    xilInfo=modelCodegenMgr.MdlRefBuildArgs.XilInfo;
    ret=~(xilInfo.IsPil);
    isKernelProfiler=codertarget.profile.internal.isKernelProfilingEnabled(hCS);
    ret=ret&&~isKernelProfiler;
    if(ret)
        if isempty(which('coder.internal.connectivity.StreamingProfilerAppSvc'))
            ret=false;
            return;
        end
        ret=codertarget.attributes.supportTargetServicesFeature(hCS,'StreamingProfilerAppSvc');
    end

    ret=ret&&codertarget.utils.isMdlConfiguredForSoC(hCS);
end


function fcnBody=i_get_upload_decl(hCS)
    h=codertarget.attributes.getTargetHardwareAttributes(hCS);

    if isnan(str2double(h.Profiler.DataLength))
        nPoints=feval(h.Profiler.DataLength,hCS);
    else
        nPoints=h.Profiler.DataLength;
    end

    if isequal(h.Profiler.InstantPrint,'1')
        fcnBody='unsigned long int _tmwrunningCoreID;';
    else
        decl1=sprintf('unsigned int profilingDataIdx = 0;');
        if isequal(h.Profiler.StoreCoreId,'1')
            decl2=sprintf('unsigned long int _tmwrunningCoreID;');
        end
        field1=sprintf('unsigned long int sectionID[%s];',nPoints);
        field2=sprintf('unsigned long int timerValue[%s];',nPoints);
        if isequal(h.Profiler.StoreCoreId,'1')
            field3=sprintf('unsigned long int coreID[%s];',nPoints);
        end
        fcnBody=sprintf('%s\n',decl1);
        if isequal(h.Profiler.StoreCoreId,'1')
            fcnBody=sprintf('%s%s\n%s\n%s\n',fcnBody,decl2);
        end
        fcnBody=sprintf('%sstruct _profilingData\n{\n',fcnBody);
        fcnBody=sprintf('%s\t%s\n\t%s\n',fcnBody,field1,field2);
        if isequal(h.Profiler.StoreCoreId,'1')
            fcnBody=sprintf('%s\t%s\n',fcnBody,field3);
        end
        fcnBody=sprintf('%s} %s;\n',fcnBody,h.Profiler.BufferName);
    end
    rtos=codertarget.targethardware.getTargetRTOS(hCS);
    if~isequal(rtos,'Baremetal')
        mutexDataType=codertarget.rtos.getPropertyForModel(hCS,'MutexDataType');
        if~isempty(mutexDataType)
            mutexDecl=sprintf('%s profilingDataStoreMutex',mutexDataType);
            fcnBody=sprintf('%s\n%s;\n',fcnBody,mutexDecl);
        end
    end
end



function fcnBody=i_get_upload_decl_streaming(hCS)



    fcnBody=sprintf('unsigned long int _tmwrunningCoreID;');
    fcnBody=sprintf('%s\n%s\n',fcnBody,'extern void uploadProfileData(void*, void*, void*);');
    rtos=codertarget.targethardware.getTargetRTOS(hCS);
    if~isequal(rtos,'Baremetal')
        mutexDataType=codertarget.rtos.getPropertyForModel(hCS,'MutexDataType');
        if~isempty(mutexDataType)
            mutexDecl=sprintf('%s profilingDataStoreMutex',mutexDataType);
            fcnBody=sprintf('%s\n%s;\n',fcnBody,mutexDecl);
        end
    end
end


function buff=i_get_upload_fcn(hCS,fcnName,atomicFcn,lTimer)
    h=codertarget.attributes.getTargetHardwareAttributes(hCS);

    if isnan(str2double(h.Profiler.DataLength))
        nPoints=feval(h.Profiler.DataLength,hCS);
    else
        nPoints=h.Profiler.DataLength;
    end

    timerDataType=lTimer.getDataType;
    bufferName=h.Profiler.BufferName;
    if~isequal(h.Profiler.InstantPrint,'1')
        line1=sprintf('\t\t%s.sectionID[profilingDataIdx] = sectionId;',bufferName);
        line2=sprintf('\t\t%s.timerValue[profilingDataIdx] = %s;',bufferName,'pTimerValue[elNum]');
        if isequal(h.Profiler.StoreCoreId,'1')
            line3=sprintf('\t\t%s.coreID[profilingDataIdx] = _tmwrunningCoreID;',bufferName);
        end
    else
        line1=sprintf('\t\t%s','printf("%lu", sectionId);');
        line2=sprintf('\t\t\t%s','printf(",%lu", pTimerValue[elNum]);');
        if isequal(h.Profiler.StoreCoreId,'1')
            line3=sprintf('\t\t\t%s','printf(",%lu\\n", _tmwrunningCoreID);');
        end
    end
    lTargetWordSize=get_param(hCS,'TargetWordSize');
    idType=sprintf('uint%d_T',coder.profile.ExecTimeConfig.getIdTypeSize(lTargetWordSize));
    fcnBody=sprintf('void %s(void * pData, %s numMemUnits, %s sectionId)\n{',fcnName,idType,idType);
    fcnBody=sprintf('%s\n\t%s_T * pTimerValue = (%s_T *) pData;',fcnBody,timerDataType,timerDataType);
    fcnBody=sprintf('%s\n\tsize_t elNum = 0;',fcnBody);
    fcnBody=sprintf('%s\n\tsize_t numEls = numMemUnits/sizeof(%s_T);',fcnBody,timerDataType);
    if~isequal(h.Profiler.InstantPrint,'1')
        fcnBody=sprintf('%s\n\tif (profilingDataIdx==%s)\n\t{',fcnBody,nPoints);
        fcnBody=sprintf('%s\n\t\treturn;',fcnBody);
        fcnBody=sprintf('%s\n\t}',fcnBody);
    end
    fcnBody=sprintf('%s\n\tfor (elNum=0; elNum<numEls; ++elNum)\n\t{',fcnBody);
    fcnBody=sprintf('%s\n%s\n%s',fcnBody,line1,line2);
    if isequal(h.Profiler.StoreCoreId,'1')
        fcnBody=sprintf('%s\n%s',fcnBody,line3);
    end
    if~isequal(h.Profiler.InstantPrint,'1')
        fcnBody=sprintf('%s\n\t\t%s',fcnBody,'profilingDataIdx++;');
    end
    fcnBody=sprintf('%s\n\t}',fcnBody);
    buff=sprintf('%s\n}\n',fcnBody);


    if~isempty(atomicFcn)
        fcnBody=sprintf('void %s(%s sectionId)\n{',atomicFcn,idType);

        rtos=codertarget.targethardware.getTargetRTOS(hCS);
        if~isequal(rtos,'Baremetal')
            mutexLockCall=codertarget.rtos.getPropertyForModel(hCS,'MutexLockCall');
            if~isempty(mutexLockCall)
                fcnBody=sprintf('%s\n\t%s(&profilingDataStoreMutex);',fcnBody,mutexLockCall);
            end
        else
            fcnBody=sprintf('%s\n%s;',fcnBody,h.getGlobalInterruptDisableCall);
        end
        if strcmp(lTimer.CountDirection,'up')
            fcnBody=sprintf('%s\n/* Using a timer that increments on each tick. */',fcnBody);
            timer_expr_prefix='';
            timer_expr_suffix='';
        else
            fcnBody=sprintf('%s\n/* Using a timer that decrements on each tick. */',fcnBody);
            timer_expr_prefix=' ~(';
            timer_expr_suffix=')';
        end
        fcnBody=sprintf('%s\n\t%s_T timerValue = %s(%s_T)%s%s;',fcnBody,timerDataType,timer_expr_prefix,timerDataType,lTimer.getReadTimerExpression,timer_expr_suffix);
        fcnBody=sprintf('%s\n%s((void *)(&timerValue), (%s)(sizeof(%s_T)), sectionId);',fcnBody,fcnName,idType,timerDataType);
        if~isequal(rtos,'Baremetal')
            mutexUnlockCall=codertarget.rtos.getPropertyForModel(hCS,'MutexUnlockCall');
            if~isempty(mutexUnlockCall)
                fcnBody=sprintf('%s\n\t%s(&profilingDataStoreMutex);',fcnBody,mutexUnlockCall);
            end
        else
            fcnBody=sprintf('%s\n%s;',fcnBody,h.getGlobalInterruptEnableCall);
        end
        fcnBody=sprintf('%s\n}\n',fcnBody);
        buff=sprintf('%s%s',buff,fcnBody);
    end
end


function buff=i_get_upload_fcn_streaming(hCS,fcnName,atomicFcn,lTimer)
    h=codertarget.attributes.getTargetHardwareAttributes(hCS);
    timerDataType=lTimer.getDataType;
    lTargetWordSize=get_param(hCS,'TargetWordSize');
    idType=sprintf('uint%d_T',coder.profile.ExecTimeConfig.getIdTypeSize(lTargetWordSize));
    fcnBody=sprintf('void %s(void * pData, %s numMemUnits, %s sectionId)\n{',fcnName,idType,idType);
    fcnBody=sprintf('%s\n\t%s_T * pTimerValue = (%s_T *) pData;',fcnBody,timerDataType,timerDataType);
    fcnBody=sprintf('%s\n\tsize_t elNum = 0;',fcnBody);
    fcnBody=sprintf('%s\n\tsize_t numEls = numMemUnits/sizeof(%s_T);',fcnBody,timerDataType);
    fcnBody=sprintf('%s\n\tfor (elNum=0; elNum<numEls; ++elNum)\n\t{',fcnBody);
    fcnBody=sprintf('%s\n\t\t%s\n',fcnBody,'uploadProfileData((void*)&sectionId, (void*)&_tmwrunningCoreID, (void*)&pTimerValue[elNum]);');
    fcnBody=sprintf('%s\n\t}',fcnBody);
    buff=sprintf('%s\n}\n',fcnBody);


    if~isempty(atomicFcn)
        fcnBody=sprintf('void %s(%s sectionId)\n{',atomicFcn,idType);

        rtos=codertarget.targethardware.getTargetRTOS(hCS);
        if~isequal(rtos,'Baremetal')
            mutexLockCall=codertarget.rtos.getPropertyForModel(hCS,'MutexLockCall');
            if~isempty(mutexLockCall)
                fcnBody=sprintf('%s\n\t%s(&profilingDataStoreMutex);',fcnBody,mutexLockCall);
            end
        else
            fcnBody=sprintf('%s\n%s;',fcnBody,h.getGlobalInterruptDisableCall);
        end
        if strcmp(lTimer.CountDirection,'up')
            fcnBody=sprintf('%s\n/* Using a timer that increments on each tick. */',fcnBody);
            timer_expr_prefix='';
            timer_expr_suffix='';
        else
            fcnBody=sprintf('%s\n/* Using a timer that decrements on each tick. */',fcnBody);
            timer_expr_prefix=' ~(';
            timer_expr_suffix=')';
        end
        fcnBody=sprintf('%s\n\t%s_T timerValue = %s(%s_T)%s%s;',fcnBody,timerDataType,timer_expr_prefix,timerDataType,lTimer.getReadTimerExpression,timer_expr_suffix);
        fcnBody=sprintf('%s\n%s((void *)(&timerValue), (%s)(sizeof(%s_T)), sectionId);',fcnBody,fcnName,idType,timerDataType);
        if~isequal(rtos,'Baremetal')
            mutexUnlockCall=codertarget.rtos.getPropertyForModel(hCS,'MutexUnlockCall');
            if~isempty(mutexUnlockCall)
                fcnBody=sprintf('%s\n\t%s(&profilingDataStoreMutex);',fcnBody,mutexUnlockCall);
            end
        else
            fcnBody=sprintf('%s\n%s;',fcnBody,h.getGlobalInterruptEnableCall);
        end
        fcnBody=sprintf('%s\n}\n',fcnBody);
        buff=sprintf('%s%s',buff,fcnBody);
    end
end


function i_insert_fcnCall(ert_main_file,searchString,fcnToInsert,isNextLine)
    ert_main=fileread(ert_main_file);
    if isNextLine
        ert_main=regexprep(ert_main,['(^[ ]*?',searchString,'\(.*?$)'],...
        sprintf('$1\n\n  %s();',fcnToInsert),'lineanchors');
    else
        ert_main=regexprep(ert_main,['(^[ ]*?',searchString,'\(.*?$)'],...
        sprintf('%s();\n\n  $1',fcnToInsert),'lineanchors');
    end
    fid=fopen(ert_main_file,'w');
    fprintf(fid,'%s',ert_main);
    fclose(fid);
    c_beautifier(ert_main_file);
end


function file_content=i_insert_task_profiling(model,file_content,lTaskRegistry,codeInfoData)

    lFullComponentPath=model;
    functionInfoForProfiling=coder.profile.ExecTimeConfig...
    .getFunctionInfoForProfiling(codeInfoData);

    functionName=functionInfoForProfiling.taskName;
    sectionIdForFunction=lTaskRegistry...
    .requestIdentifierForTask(functionName,...
    functionInfoForProfiling,...
    lFullComponentPath);
    codeIdentifiers=lTaskRegistry.getCodeIdentifiers(...
    coder_profile_ProbeType.TASK_TIME_PROBE);

    profStart=sprintf('%s(%dU);',...
    codeIdentifiers.startMacroName,sectionIdForFunction);
    profEnd=sprintf('%s(%dU);',...
    codeIdentifiers.endMacroName,sectionIdForFunction);
    if~contains(file_content,profStart)
        insertProxyTaskLoadFcn=false;
        if codertarget.utils.isESBEnabled(model)&&...
            isequal(codeInfoData.Timing.TimingMode,'PERIODIC')
            rateID=(sectionIdForFunction-2)/2;
            if isequal(rateID,0)
                insertProxyTaskLoadFcn=soc.internal.isProxyTaskBlockInBaseRate(model);
            else
                insertProxyTaskLoadFcn=soc.internal.isProxyTaskBlockInSubRate(model);
            end
        end
        if insertProxyTaskLoadFcn
            file_content=regexprep(file_content,['(^[ ]*?',functionName,'\(.*?$)'],...
            sprintf('%s\n$1\n%s(%d);\n%s',profStart,'mw_cpuloadgenerator',...
            rateID,profEnd),'lineanchors');
        else
            file_content=regexprep(file_content,['(^[ ]*?',functionName,'\(.*?$)'],...
            sprintf('%s\n$1\n%s',profStart,profEnd),'lineanchors');
        end
    end

    if codertarget.utils.isESBEnabled(model)

        if(~(contains(functionName,'_initialize')||contains(functionName,'_terminate')))
            if contains(functionName,'_step')
                functionName=strcat(functionInfoForProfiling.taskName,'_drop');
                lTaskRegistry.requestIdentifierForTask(functionName,...
                functionInfoForProfiling,...
                lFullComponentPath);
            end
        end
    end
end


function[file_content,taskInfo]=i_insert_taskblock_profiling(model,file_content,lTaskRegistry,taskInfo)

    lFullComponentPath=model;
    occurance=1;
    functionInfoForProfiling=struct('taskName',taskInfo.name,...
    'samplePeriod',Inf,...
    'sampleOffset',0);

    if codertarget.utils.isESBEnabled(model)

        functionName=strcat(functionInfoForProfiling.taskName,'_drop');
        lTaskRegistry.requestIdentifierForTask(functionName,...
        functionInfoForProfiling,...
        lFullComponentPath);
    end

    functionName=functionInfoForProfiling.taskName;
    sectionIdForFunction=lTaskRegistry...
    .requestIdentifierForTask(functionName,...
    functionInfoForProfiling,...
    lFullComponentPath);
    codeIdentifiers=lTaskRegistry.getCodeIdentifiers(...
    coder_profile_ProbeType.TASK_TIME_PROBE);

    profStart=sprintf('%s(%dU);',...
    codeIdentifiers.startMacroName,sectionIdForFunction);
    profEnd=sprintf('%s(%dU);',...
    codeIdentifiers.endMacroName,sectionIdForFunction);
    if(taskInfo.tid~=sectionIdForFunction)
        if~mod(taskInfo.tid,2)
            occurance=2;
        end
    end

    file_content=regexprep(file_content,['taskTimeStart_\(',num2str(taskInfo.tid),'U\);'],profStart,occurance);
    file_content=regexprep(file_content,['taskTimeEnd_\(',num2str(taskInfo.tid),'U\);'],profEnd,occurance);
    taskInfo.tid=sectionIdForFunction;
end



function file_content=i_insert_task_profiling_for_step_fcn(model,file_content,...
    lTaskRegistry,codeInfoData,tid01eq)

    lFullComponentPath=model;
    functionInfoForProfiling=coder.profile.ExecTimeConfig...
    .getFunctionInfoForProfiling(codeInfoData);

    functionName=functionInfoForProfiling.taskName;
    sectionIdForFunction=lTaskRegistry...
    .requestIdentifierForTask(functionName,...
    functionInfoForProfiling,...
    lFullComponentPath);
    codeIdentifiers=lTaskRegistry.getCodeIdentifiers(...
    coder_profile_ProbeType.TASK_TIME_PROBE);

    rateName=codeInfoData.ActualArgs.GraphicalName;
    if isequal(rateName,'TID0')
        expr1='\(0.*?$)';
        profStart=sprintf('%s(%dU);',...
        codeIdentifiers.startMacroName,sectionIdForFunction);
        profEnd=sprintf('%s(%dU);',...
        codeIdentifiers.endMacroName,sectionIdForFunction);
        if~isempty(regexp(file_content,'mw_cpuloadgenerator\(0\)','once'))
            file_content=regexprep(file_content,'mw_cpuloadgenerator\(0\);','');
            file_content=regexprep(file_content,['(^[ ]*?',functionName,expr1],...
            sprintf('%s\n$1\n%s\n%s',profStart,...
            'mw_cpuloadgenerator(0);',profEnd),'lineanchors');
        else
            file_content=regexprep(file_content,['(^[ ]*?',functionName,expr1],...
            sprintf('%s\n$1\n%s',profStart,profEnd),'lineanchors');
        end
    elseif(~tid01eq&&isequal(rateName,'TID1'))||...
        (tid01eq&&isequal(rateName,'TID2'))
        expr1='\(subRateId.*?$)';

        if codertarget.utils.isESBEnabled(model)
            profStart=sprintf('%s(%dU + subRateId*2);',...
            codeIdentifiers.startMacroName,sectionIdForFunction-2);
            profEnd=sprintf('%s(%dU + subRateId*2);',...
            codeIdentifiers.endMacroName,sectionIdForFunction-2);
        else
            profStart=sprintf('%s(%dU + subRateId);',...
            codeIdentifiers.startMacroName,sectionIdForFunction-1);
            profEnd=sprintf('%s(%dU + subRateId);',...
            codeIdentifiers.endMacroName,sectionIdForFunction-1);
        end

        if~isempty(regexp(file_content,'mw_cpuloadgenerator\(subRateId\)','once'))
            file_content=regexprep(file_content,'mw_cpuloadgenerator\(subRateId\);','');
            file_content=regexprep(file_content,['(^[ ]*?',functionName,expr1],...
            sprintf('%s\n$1\n%s\n%s',profStart,...
            'mw_cpuloadgenerator(subRateId);',profEnd),'lineanchors');
        else
            file_content=regexprep(file_content,['(^[ ]*?',functionName,expr1],...
            sprintf('%s\n$1\n%s',profStart,profEnd),'lineanchors');
        end
    end

    if codertarget.utils.isESBEnabled(model)

        functionName=strcat(functionInfoForProfiling.taskName,'_drop');
        lTaskRegistry.requestIdentifierForTask(functionName,...
        functionInfoForProfiling,...
        lFullComponentPath);
    end
end


function codeDir=locGetSourceCodeFolder(model,buildInfo)




    codeDir=buildInfo.getSourceFiles(true,true,'BuildDir');
    modeFileName=[model,'.c'];
    idx=find(contains(codeDir,modeFileName),1);
    codeDir=fileparts(codeDir{idx});
end
