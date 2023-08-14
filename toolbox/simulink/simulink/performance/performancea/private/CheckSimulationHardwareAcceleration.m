function[ResultDescription,ResultDetails]=CheckSimulationHardwareAcceleration(system)






    ResultDescription={};
    ResultDetails={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    model=bdroot(system);
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.CheckSimulationHardwareAcceleration');


    Pass=true;

    mdladvObj.UserData.SimHardwareAcceleration.ResultData={};


    Passed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Passed'),{'bold','pass'});
    Failed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Failed'),{'bold','fail'});
    Warned=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Warning'),{'bold','warn'});


    result_paragraph=ModelAdvisor.Paragraph;


    baseLineBefore=utilGetOverallBaseline(mdladvObj);

    baseLineAfter=utilCreateEmptyBaseline(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimHardwareAccelCheckTitle'));

    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);


    cfs=utilGetActiveConfigSet(model);
    configSet=cfs.configSet;




    oldStopTime=get_param(model,'StopTime');

    simMode=get_param(model,'SimulationMode');
    isNormal=strcmpi(simMode,'normal');
    isAccelerator=strcmpi(simMode,'accelerator');
    isRapidAccelerator=strcmpi(simMode,'rapid-accelerator');
    hasDataflow=~isempty(Simulink.findBlocksOfType(model,'SubSystem','SetExecutionDomain','on','ExecutionDomainType','Dataflow'));
    hasSysBlk=~isempty(Simulink.findBlocksOfType(model,'MATLABSystem','SimulateUsing','Code generation'));
    isClassicAccel=strcmpi(get_param(0,'GlobalUseClassicAccelMode'),'on')&&isAccelerator;


    originalSimHardAccel=get_param(model,'SimHardwareAcceleration');
    originalVerboseValue=get_param(model,'AccelVerboseBuild');

    isLCC=false;
    comp=rtwprivate('getMexCompilerInfo');
    if(isempty(comp)||(sfpref('UseLCC64ForSimulink')&&...
        strcmpi(computer('arch'),'win64')))
        isLCC=true;
    else
        compilerName=lower(comp(1).compStr);
        if(contains(compilerName,'lcc'))
            isLCC=true;
        end
    end

    if~(isAccelerator||isRapidAccelerator||hasDataflow||hasSysBlk)
        Pass=true;
        result_paragraph.addItem(Passed);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimHardwareAccelNotCodegenSimMode'));
        result_paragraph.addItem(text);
    elseif(isLCC&&~(isAccelerator||hasSysBlk))
        Pass=true;
        result_paragraph.addItem(Passed);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimHardwareAccelLCCCompiler'));
        result_paragraph.addItem(text);
    else

        if strcmpi(originalSimHardAccel,'off')
            oldValueLabel=DAStudio.message('RTW:configSet:SimHardwareAcceleration_Off');
        elseif strcmpi(originalSimHardAccel,'generic')
            oldValueLabel=DAStudio.message('RTW:configSet:SimHardwareAcceleration_Generic');
        else
            oldValueLabel=DAStudio.message('RTW:configSet:SimHardwareAcceleration_Native');
        end


        evalc('cgxe(''Feature'', ''DumpModulefromLLVM'', ''on'')');
        set_param(model,'AccelVerboseBuild','on');

        try
            stopTime=utilGetBaselineStopTime(mdladvObj,model);


            cleanFolder(model);
            configSet.set_param('SimHardwareAcceleration','off');
            [HAccelOffPerfData.totalTime,...
            HAccelOffPerfData.Tu,...
            HAccelOffPerfData.Tuc,...
            HAccelOffPerfData.Ts,...
            HAccelOffPerfData.Tg,...
            HAccelOffPerfData.Tmrb,...
            HAccelOffPerfData.Te,...
            HAccelOffPerfData.Tt]=utilGetTimingInfo(model,false);
            HAccelOffPerfData.simHardAccel=configSet.get_param('SimHardwareAcceleration');
            HAccelOffPerfData.simHardAccel_label=DAStudio.message('RTW:configSet:SimHardwareAcceleration_Off');
            HAccelOffPerfData.simHardAccel_oldLabel=oldValueLabel;
            HAccelOffPerfData.levHard='None';


            cleanFolder(model);
            configSet.set_param('SimHardwareAcceleration','generic');
            [HAccelGenPerfData.totalTime,...
            HAccelGenPerfData.Tu,...
            HAccelGenPerfData.Tuc,...
            HAccelGenPerfData.Ts,...
            HAccelGenPerfData.Tg,...
            HAccelGenPerfData.Tmrb,...
            HAccelGenPerfData.Te,...
            HAccelGenPerfData.Tt]=utilGetTimingInfo(model,false);
            HAccelGenPerfData.simHardAccel=configSet.get_param('SimHardwareAcceleration');
            HAccelGenPerfData.simHardAccel_label=DAStudio.message('RTW:configSet:SimHardwareAcceleration_Generic');
            HAccelGenPerfData.simHardAccel_oldLabel=oldValueLabel;
            HAccelGenPerfData.levHard=getLeveragedHardware(model,isAccelerator);


            cleanFolder(model);
            configSet.set_param('SimHardwareAcceleration','native');
            [HAccelNatPerfData.totalTime,...
            HAccelNatPerfData.Tu,...
            HAccelNatPerfData.Tuc,...
            HAccelNatPerfData.Ts,...
            HAccelNatPerfData.Tg,...
            HAccelNatPerfData.Tmrb,...
            HAccelNatPerfData.Te,...
            HAccelNatPerfData.Tt]=utilGetTimingInfo(model,false);
            HAccelNatPerfData.simHardAccel=configSet.get_param('SimHardwareAcceleration');
            HAccelNatPerfData.simHardAccel_label=DAStudio.message('RTW:configSet:SimHardwareAcceleration_Native');
            HAccelNatPerfData.simHardAccel_oldLabel=oldValueLabel;
            HAccelNatPerfData.levHard=getLeveragedHardware(model,isAccelerator);
            cleanFolder();

        catch me

            cleanFolder(model);

            configSet.set_param('SimHardwareAcceleration',originalSimHardAccel);
            set_param(model,'AccelVerboseBuild',originalVerboseValue);
            evalc('cgxe(''Feature'', ''DumpModulefromLLVM'', ''off'')');


            mdladvObj.setCheckResultStatus(false);
            mdladvObj.setCheckErrorSeverity(1);
            mdladvObj.setActionEnable(false);

            [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,me.message,me.cause);
            return;
        end

        configSet.set_param('SimHardwareAcceleration',originalSimHardAccel);

        set_param(model,'AccelVerboseBuild',originalVerboseValue);
        evalc('cgxe(''Feature'', ''DumpModulefromLLVM'', ''off'')');


        bestDataSet=HAccelOffPerfData;
        if bestDataSet.Te>HAccelGenPerfData.Te
            bestDataSet=HAccelGenPerfData;
        end
        if bestDataSet.Te>HAccelNatPerfData.Te
            bestDataSet=HAccelNatPerfData;
        end


        genNone=strcmpi(HAccelGenPerfData.levHard,DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimHardwareAccelTableNone'));
        natNone=strcmpi(HAccelNatPerfData.levHard,DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimHardwareAccelTableNone'));
        genSIMD=~(genNone&&natNone);



        Pass=(~genSIMD)||strcmpi(bestDataSet.simHardAccel,originalSimHardAccel);


        WriteCheckResults(mdladvObj,bestDataSet);


        if~Pass
            actionMode=utilCheckActionMode(mdladvObj,currentCheck);
            if contains(actionMode,'Manually')
                action=currentCheck.getAction;
                fixButtonName=action.Name;
                result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimHardwareAccelnAdviceManually',oldValueLabel,system,bestDataSet.simHardAccel_label,fixButtonName));
                result_paragraph.addItem(result_text);
                result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
            else
                result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:AdviceAppendAuto'));
                result_paragraph.addItem(result_text);
                result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
            end

        else

            result_paragraph.addItem(Passed);
            result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
            if genSIMD
                result_paragraph.addItem(ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimHardwareAccelPassed',oldValueLabel)));
            else
                result_paragraph.addItem(ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimHardwareAccelNoSIMD',oldValueLabel)));
            end
            result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        end

        text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimHardwareAccelTablesInfo'));
        result_paragraph.addItem(text);
        result_paragraph.addItem([ModelAdvisor.LineBreak]);


        table2=cell(3,3);


        table2{1,1}=HAccelOffPerfData.simHardAccel_label;
        table2{2,1}=HAccelGenPerfData.simHardAccel_label;
        table2{3,1}=HAccelNatPerfData.simHardAccel_label;


        table2{1,2}=sprintf('%.3f',HAccelOffPerfData.Te);
        table2{2,2}=sprintf('%.3f',HAccelGenPerfData.Te);
        table2{3,2}=sprintf('%.3f',HAccelNatPerfData.Te);


        table2{1,3}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimHardwareAccelTableNone');
        table2{2,3}=HAccelGenPerfData.levHard;
        table2{3,3}=HAccelNatPerfData.levHard;


        tableName2=ModelAdvisor.Text('Hardware Acceleration Simulation Results Data',{'bold'});
        h1=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimHardwareAccelTableHardwareAccel'));
        h2=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimHardwareAccelTableSimTime'));
        h3=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimHardwareAccelTableLeveragedHardware'));
        heading2={h1,h2,h3};
        resultTable=utilDrawReportTable(table2,tableName2,{},heading2);
        result_paragraph.addItem(ModelAdvisor.LineBreak);
        result_paragraph.addItem(resultTable.emitHTML);



        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        cpuTable=getCPUTable();
        result_paragraph.addItem(cpuTable.emitHTML);


    end


    ResultDescription{end+1}=result_paragraph;
    ResultDetails{end+1}='';


    mdladvObj.setCheckResultStatus(Pass);

    if~Pass

        mdladvObj.setCheckErrorSeverity(0);


        utilRunFix(mdladvObj,currentCheck,Pass);
    end



    if(Pass)
        baseLineAfter.time=baseLineBefore.time;
        baseLineAfter.check.passed='y';
    else
        baseLineAfter=utilGetBaselineAfter(mdladvObj,model,currentCheck);
        baseLineAfter.check.passed='n';
    end
    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);

end


function WriteCheckResults(mdladvObj,bestDataSet)






    mdladvObj.UserData.SimHardwareAcceleration.ResultData=bestDataSet;
end

function simd=getLeveragedHardware(model,isAccelerator)
    simd=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimHardwareAccelTableNone');
    hitCache=getHitCacheSIMD(model);
    if~isempty(hitCache)
        simd=hitCache;
    else
        llvmSIMD=getLLVMSIMD(model,isAccelerator);
        if~isempty(llvmSIMD)
            simd=llvmSIMD;
        end
    end
end

function simd=getHitCacheSIMD(model)
    simd='';
    fcnLib=get_param(model,'SimTargetFcnLibHandle');
    for i=1:numel(fcnLib.HitCache)
        if contains(fcnLib.HitCache(i).UID,'avx512')
            simd='AVX512f';
            return;
        elseif contains(fcnLib.HitCache(i).UID,'avx')
            simd='AVX2';
            return;
        elseif contains(fcnLib.HitCache(i).UID,'sse4')
            simd='SSE4.1';
            return;
        elseif contains(fcnLib.HitCache(i).UID,'sse')
            simd='SSE2';
            return;
        end
    end
end

function simd=getLLVMSIMD(model,isAccelerator)
    simd='';
    sse2Pattern="load <";


    jitEnginesInfo=cgxe('getJITEngines');
    if~isempty(jitEnginesInfo)
        allModuleContent=strcat(jitEnginesInfo(:).DumpModule);
        if contains(allModuleContent,sse2Pattern)
            simd='SSE2';
        end
    end


    if(isAccelerator)
        srcFilePath=fullfile(pwd,'slprj','accel',model,strcat(model,'_top_vm.ll'));
        if isfile(srcFilePath)
            accelIR=fileread(srcFilePath);
            if contains(accelIR,sse2Pattern)
                simd='SSE2';
            end
        end
    end



end

function cpuTable=getCPUTable()

    function comma=addComma(exts)
        if isempty(exts)
            comma='';
        else
            comma=',';
        end
    end

    cpuInfo=private_sl_CPUInfo;
    exts='';
    if(cpuInfo.SSE2)
        exts=[exts,'SSE2'];
    end
    if(cpuInfo.SSE41)
        exts=[exts,addComma(exts),' SSE4.1'];
    end
    if(cpuInfo.AVX2)
        exts=[exts,addComma(exts),' AVX2'];
    end
    if(cpuInfo.AVX512)
        exts=[exts,addComma(exts),' AVX512f'];
    end
    if~(cpuInfo.SSE2||cpuInfo.SSE41||cpuInfo.AVX2||cpuInfo.AVX512)
        exts='None';
    end

    cpuTable=cell(1,2);
    cpuTable{1,1}=ModelAdvisor.Text(cpuInfo.CPUID);
    cpuTable{1,2}=ModelAdvisor.Text(exts);
    cpuTableHeading={ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimHardwareAccelHardwareInfoTableCPU')),...
    ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimHardwareAccelHardwareInfoTableSupportedHardware'))};
    cpuTableName=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimHardwareAccelHardwareInfoTableTitle'),{'bold'});
    cpuTable=utilDrawReportTable(cpuTable,cpuTableName,{},cpuTableHeading);

end











function cleanFolder(model)
    try
        if(exist(['slprj',filesep,'sim'],'dir')~=0)
            rmdir(['slprj',filesep,'sim'],'s');
        end
        if(exist(['slprj',filesep,'accel'],'dir')~=0)
            rmdir(['slprj',filesep,'accel'],'s');
        end
        if(exist(['slprj',filesep,'raccel'],'dir')~=0)
            rmdir(['slprj',filesep,'raccel'],'s');
        end
        if(exist(['slprj',filesep,'_sfprj'],'dir')~=0)
            rmdir(['slprj',filesep,'_sfprj'],'s');
        end
        clear mex;
        mexFilePats={['.*_acc\.',mexext],...
        ['.*_msf\.',mexext],...
        ['.*_sfun\.',mexext]};
        w=what;
        for fileindex=1:length(w.mex)
            for patindex=1:length(mexFilePats)
                isMexFile=regexp(w.mex{fileindex},mexFilePats{patindex},'once');
                if(~isempty(isMexFile))
                    if mislocked(w.mex{fileindex})
                        munlock(w.mex{fileindex});
                    end
                    delete(w.mex{fileindex});
                end
            end
        end
        cgxe('clearJITEngines');
        tfl=get_param(model,'SimTargetFcnLibHandle');
        tfl.resetUsageCounts;

    catch me %#ok<*NASGU>

    end
end
