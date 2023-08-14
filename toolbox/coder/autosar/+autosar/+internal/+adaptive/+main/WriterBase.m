classdef WriterBase<handle









    properties(Access=protected)
        CodeWriterObj;
        CodeInfo;
        XcpParams;
    end

    methods(Abstract,Access=public)
        writeReportExecutionState(this,state);
        includeLogHeaders(this);
    end

    methods(Static,Access=public)
        function mainWriterObj=create(codeInfo,schemaVer,bdir,writerObj,xcpParams)






            if nargin<5
                xcpParams=struct('AdaptiveAutosarXCPSlaveTransportLayer','None');
            end

            if(nargin>3)&&~isempty(writerObj)
                codeWriterObj=rtw.connectivity.CodeWriter.create(...
                'callCBeautifier',true,...
                'writerObject',writerObj);
            else
                cppfile=fullfile(bdir,'main.cpp');
                codeWriterObj=rtw.connectivity.CodeWriter.create(...
                'callCBeautifier',true,...
                'filename',cppfile,...
                'append',false);
            end
            if strcmp(schemaVer,'R18-10')
                mainWriterObj=autosar.internal.adaptive.main.Writer1810(codeWriterObj,codeInfo,xcpParams);
            elseif strcmp(schemaVer,'R19-03')
                mainWriterObj=autosar.internal.adaptive.main.Writer1903(codeWriterObj,codeInfo,xcpParams);
            elseif strcmp(schemaVer,'R19-11')
                mainWriterObj=autosar.internal.adaptive.main.Writer1911(codeWriterObj,codeInfo,xcpParams);
            elseif strcmp(schemaVer,'R20-11')
                mainWriterObj=autosar.internal.adaptive.main.Writer2011(codeWriterObj,codeInfo,xcpParams);
            else
                assert(false,'AUTOSAR Schema greater than R21-11 is not supported yet');
            end
        end
    end
    methods(Access=public)
        function this=WriterBase(codeWriterObj,codeInfo,xcpParams)
            this.CodeWriterObj=codeWriterObj;
            this.CodeInfo=codeInfo;
            this.XcpParams=xcpParams;
        end

        function generate(this)


            this.CodeWriterObj.wComment(sprintf('Code generated for Simulink model %s',this.CodeInfo.Name));
            this.CodeWriterObj.wComment(sprintf('Generated on %s',date));

            this.IncludeHeaders();

            this.CodeWriterObj.wBlockStart('namespace mwSync');
            this.CodeWriterObj.wComment('To synchronize between the main thread and signal handler, ');
            this.CodeWriterObj.wComment('the following semaphore and boolean flag will be used.');
            this.CodeWriterObj.wComment('They must both be global so the main thread and signal ');
            this.CodeWriterObj.wComment('handler can access them.');
            this.CodeWriterObj.wLine('static sem_t baserate_tick;');
            this.CodeWriterObj.wLine('static bool halt_application{false};');

            this.CodeWriterObj.wComment('This is the signal handler which is called:');
            this.CodeWriterObj.wComment(' - When the base rate timer expires');
            this.CodeWriterObj.wComment(' - When we need to terminate');
            this.CodeWriterObj.wComment('It posts to a semaphore which tells main to do another ');
            this.CodeWriterObj.wComment('step or terminate.');
            this.CodeWriterObj.wBlockStart('static void signal_handler(int32_t signalNum)');
            this.BaserateTimer();
            this.CodeWriterObj.wBlockEnd();
            this.CodeWriterObj.wBlockEnd();

            this.CodeWriterObj.wComment('main() handles the following:');
            this.CodeWriterObj.wComment(' - Instantiates the model object and owns its memory.');
            this.CodeWriterObj.wComment(' - Reports the Execution state to ARA');
            this.CodeWriterObj.wComment(' - Calls the model''s initialize and terminate functions.');
            this.CodeWriterObj.wComment(' - Sets up AsyncFunctionCall objects for each task');
            this.CodeWriterObj.wComment('     - Since AsyncFunctionCalls create threads, main also ');
            this.CodeWriterObj.wComment('       temporarily blocks SIGRTMIN and SIGTERM, so the threads ');
            this.CodeWriterObj.wComment('       will inherit the block and not respond to those ');
            this.CodeWriterObj.wComment('       signals.');
            this.CodeWriterObj.wComment(' - Responds to baserate_tick semaphore posts and runs ');
            this.CodeWriterObj.wComment('    applicable AsyncFunctionCalls.');
            this.CodeWriterObj.wBlockStart('int32_t main()');
            this.MainBody();
            this.CodeWriterObj.wBlockEnd();

            this.CodeWriterObj.close;
        end
    end

    methods(Access=private)
        function BaserateTimer(this)
            this.CodeWriterObj.wBlockStart('if(signalNum == SIGTERM)');
            this.CodeWriterObj.wLine('halt_application = true;');
            this.CodeWriterObj.wBlockEnd();
            this.CodeWriterObj.wLine('static_cast<void>(sem_post(&baserate_tick));');
        end

        function IncludeHeaders(this)
            this.CodeWriterObj.wLine('#include <thread>');
            this.CodeWriterObj.wLine('#include <semaphore.h>');
            this.CodeWriterObj.wLine('#include <exception>');
            this.CodeWriterObj.wLine('#include <csignal>');
            this.CodeWriterObj.wLine('#include <ara/core/initialization.h>');
            this.CodeWriterObj.wLine('#include <ara/exec/execution_client.h>');
            includeLogHeaders(this);
            this.CodeWriterObj.wLine('#include "MainUtils.hpp"');

            if~strcmp(this.XcpParams.AdaptiveAutosarXCPSlaveTransportLayer,'None')
                this.CodeWriterObj.wLine('#ifdef __cplusplus');
                this.CodeWriterObj.wLine('extern "C" {');
                this.CodeWriterObj.wLine('#endif');
                this.CodeWriterObj.wLine('#include "xcp_slave.h"');
                this.CodeWriterObj.wLine('#ifdef __cplusplus');
                this.CodeWriterObj.wLine('}');
                this.CodeWriterObj.wLine('#endif');
            end

            headers=string.empty();
            functions={this.CodeInfo.OutputFunctions,...
            this.CodeInfo.InitializeFunctions,...
            this.CodeInfo.TerminateFunctions};

            headersRemaining=0;
            for ii=1:length(functions)
                headersRemaining=headersRemaining+length(functions{ii});
            end

            for ii=1:length(functions)
                fun=functions{ii};
                for jj=1:length(fun)
                    proto=fun(jj).Prototype;
                    headers(headersRemaining)=convertCharsToStrings(proto.HeaderFile);
                    headersRemaining=headersRemaining-1;
                end
            end
            assert(headersRemaining==0);

            if~isempty(headers)
                headers=unique(headers);
                for ii=1:length(headers)
                    this.CodeWriterObj.wLine('#include "%s"',headers(ii));
                end
            end



            if~isempty(this.CodeInfo.InternalData)&&...
                ~strcmp(this.XcpParams.AdaptiveAutosarXCPSlaveTransportLayer,'None')
                modelClassObjectName=this.CodeInfo.InternalData(1).Implementation.Identifier;
                modelClass=this.CodeInfo.InternalData(1).Implementation.Type.Identifier;
                this.CodeWriterObj.wLine('%s %s;',modelClass,modelClassObjectName);
            end
        end

        function MainBody(this)

            this.CodeWriterObj.wComment('Failure return value for signal/semaphore api''s.');
            this.CodeWriterObj.wLine('constexpr int32_t SIG_RET_FAIL{-1};');

            this.CodeWriterObj.wComment('Used to control the flow in case of error in any api''s used.');
            this.CodeWriterObj.wLine('bool bProceed{true};');
            this.CodeWriterObj.wComment('Used to decide whether ara function clusters has been initialized.');
            this.CodeWriterObj.wLine('bool bAraInitialized{true};');

            this.CodeWriterObj.wComment('ara function cluster init.');
            this.CodeWriterObj.wLine('const ara::core::Result<void> initStatus{ara::core::Initialize()};')
            this.CodeWriterObj.wBlockStart('if(!initStatus.HasValue())');
            this.CodeWriterObj.wLine('bProceed =  false;');
            this.CodeWriterObj.wLine('bAraInitialized = false;');
            this.CodeWriterObj.wBlockEnd();

            this.CodeWriterObj.wBlockStart('if(bAraInitialized)');
            this.CodeWriterObj.wLine('ara::log::Logger & araLog{ara::log::CreateLogger("%s", "Logger for %s''s main function.")};',...
            this.CodeInfo.Name,this.CodeInfo.Name);
            this.CodeWriterObj.wNewLine;

            this.CodeWriterObj.wBlockStart('if(bProceed)')
            this.CodeWriterObj.wBlockStart('if (sem_init(&mwSync::baserate_tick, 0, 0) == SIG_RET_FAIL)');
            this.CodeWriterObj.wLine('araLog.LogError()<<"Unable to initialize baserate_tick semaphore.\n";');
            this.CodeWriterObj.wLine('bProceed =  false;');
            this.CodeWriterObj.wBlockEnd();
            this.CodeWriterObj.wBlockEnd();

            this.CodeWriterObj.wBlockStart('if(bProceed)')
            this.CodeWriterObj.wComment('Register handler for SIGTERM');
            this.CodeWriterObj.wLine('struct sigaction action;');
            this.CodeWriterObj.wLine('static_cast<void>(sigemptyset(&action.sa_mask));');
            this.CodeWriterObj.wLine('action.sa_handler = &mwSync::signal_handler;');
            this.CodeWriterObj.wLine('action.sa_flags = 0;');
            this.CodeWriterObj.wBlockStart('if (sigaction(SIGTERM, &action, nullptr) == SIG_RET_FAIL)');
            this.CodeWriterObj.wLine('araLog.LogError()<<"Unable to register SIGTERM handler.\n";');
            this.CodeWriterObj.wLine('bProceed =  false;');
            this.CodeWriterObj.wBlockEnd();
            this.CodeWriterObj.wBlockEnd();

            this.CodeWriterObj.wComment('Report Execution state');
            this.CodeWriterObj.wLine('ara::exec::ExecutionClient exec_client;');


            this.CodeWriterObj.wBlockStart('try');
            this.writeReportExecutionState('kRunning');
            this.CodeWriterObj.wLine('araLog.LogError()<<"Unable to report running state: ara::exec::ExecutionReturnType::kGeneralError.\n";');
            this.CodeWriterObj.wLine('bProceed = false;');
            this.CodeWriterObj.wBlockMiddle('else');
            this.CodeWriterObj.wLine('araLog.LogVerbose()<<"Adaptive application entering running state.";');
            this.CodeWriterObj.wBlockEnd;
            this.CodeWriterObj.wBlockMiddle('catch(std::exception const & e)');
            this.CodeWriterObj.wLine('araLog.LogError()<<"Unable to report running state due to exception: "<<e.what()<<".\n";');
            this.CodeWriterObj.wLine('bProceed = false;');
            this.CodeWriterObj.wBlockEnd;



            if~isempty(this.CodeInfo.InternalData)
                modelClassObjectName=this.CodeInfo.InternalData(1).Implementation.Identifier;
                modelClass=this.CodeInfo.InternalData(1).Implementation.Type.Identifier;
                if strcmp(this.XcpParams.AdaptiveAutosarXCPSlaveTransportLayer,'None')
                    this.CodeWriterObj.wLine('%s %s;',modelClass,modelClassObjectName);
                end
            else
                modelClass=strcat(this.CodeInfo.Name,'ModelClass');
                modelClassObjectName='model';
                this.CodeWriterObj.wLine('%s %s;',modelClass,modelClassObjectName);
            end


            this.CodeWriterObj.wBlockStart('if(bProceed)')

            if~strcmp(this.XcpParams.AdaptiveAutosarXCPSlaveTransportLayer,'None')
                argList={};
                argList{end+1}='-port';
                argList{end+1}=this.XcpParams.AdaptiveAutosarXCPSlavePort;
                if strcmp(this.XcpParams.AdaptiveAutosarXCPSlaveTransportLayer,'XCPOnTCPIP')
                    argList{end+1}='-protocol';
                    argList{end+1}='TCP';
                end
                argList{end+1}='-verbose';
                if strcmp(this.XcpParams.AdaptiveAutosarXCPSlaveVerbosity,'on')
                    argList{end+1}='1';
                else
                    argList{end+1}='0';
                end

                this.CodeWriterObj.wComment('Arguments for XCP Slave Transport Layer as specified in Model Settings (configset).');
                this.CodeWriterObj.wLine(['int32_t lArgc = ',num2str(numel(argList)),';']);
                this.CodeWriterObj.wLine('const void* lArgv[] = {');
                this.CodeWriterObj.wLine('"%s", "%s"',argList{1},argList{2});

                for ii=3:2:numel(argList)
                    this.CodeWriterObj.wLine(',"%s", "%s"',argList{ii},argList{ii+1});
                end

                this.CodeWriterObj.wLine('};');
            end

            this.CodeWriterObj.wComment('Initialize Functions');
            this.CodeWriterObj.wBlockStart('try');
            for ii=1:length(this.CodeInfo.InitializeFunctions)
                initfun=this.CodeInfo.InitializeFunctions(ii);

                this.CodeWriterObj.wLine('%s.%s();',modelClassObjectName,initfun.Prototype.Name);
            end
            if~strcmp(this.XcpParams.AdaptiveAutosarXCPSlaveTransportLayer,'None')
                this.CodeWriterObj.wBlockStart('if(xcpSlaveInit(lArgc, lArgv))');
                this.CodeWriterObj.wLine('araLog.LogError()<<"XCP Initialization failed.\n";');
                this.CodeWriterObj.wLine('bProceed = false;');
                this.CodeWriterObj.wBlockMiddle('else');
                this.CodeWriterObj.wLine('araLog.LogVerbose()<<"XCP Slave initialized successfully.\n";');
                this.CodeWriterObj.wBlockEnd();
            end
            this.CodeWriterObj.wBlockMiddle('catch(std::exception const & e)');
            this.CodeWriterObj.wLine('araLog.LogError()<<"Unable to initialize: "<<e.what()<<".\n";');
            this.CodeWriterObj.wLine('bProceed = false;');
            this.CodeWriterObj.wBlockEnd();
            this.CodeWriterObj.wBlockEnd;


            this.CodeWriterObj.wBlockStart('if(bProceed)')
            this.CodeWriterObj.wComment('Before spawning threads with StepFunction objects, ');
            this.CodeWriterObj.wComment('block signals so the threads will not receive them.');
            this.CodeWriterObj.wLine('block_signals(araLog);');

            numOutputFunctions=length(this.CodeInfo.OutputFunctions);
            if numOutputFunctions
                periodicIndexes(numOutputFunctions)=false;
                asynchronousIndexes(numOutputFunctions)=false;
                unknownIndexes(numOutputFunctions)=false;
                for ii=numOutputFunctions:-1:1
                    outfun=this.CodeInfo.OutputFunctions(ii);
                    switch outfun.Timing.TimingMode
                    case 'PERIODIC'
                        periodicIndexes(ii)=true;
                    case 'ASYNCHRONOUS'
                        asynchronousIndexes(ii)=true;
                    otherwise
                        unknownIndexes(ii)=true;
                    end
                end

                asynchronousFunctions=this.CodeInfo.OutputFunctions(asynchronousIndexes);
                if~isempty(asynchronousFunctions)
                    this.CodeWriterObj.wComment('Simulink supports scheduling Adaptive AUTOSAR tasks');
                    this.CodeWriterObj.wComment('periodically, but some asynchronous tasks were found');
                    this.CodeWriterObj.wComment('in the model.  To schedule these tasks, manually call the');
                    this.CodeWriterObj.wComment('functions commented out below:');
                    for ii=1:length(asynchronousFunctions)
                        outfun=asynchronousFunctions(ii);
                        name=outfun.Prototype.Name;
                        this.CodeWriterObj.wComment(sprintf('%s();',name));
                    end
                end

                unknownFunctions=this.CodeInfo.OutputFunctions(unknownIndexes);
                if~isempty(unknownFunctions)
                    this.CodeWriterObj.wComment('Simulink supports scheduling Adaptive AUTOSAR tasks');
                    this.CodeWriterObj.wComment('periodically, but some unhandled tasks were found');
                    this.CodeWriterObj.wComment('in the model.  To schedule these tasks, manually call the');
                    this.CodeWriterObj.wComment('functions commented out below:');
                    for ii=1:length(unknownFunctions)
                        outfun=unknownFunctions(ii);
                        name=outfun.Prototype.Name;
                        this.CodeWriterObj.wComment(sprintf('%s();',name));
                    end
                end

                periodicFunctions=this.CodeInfo.OutputFunctions(periodicIndexes);





                isPeriodic=arrayfun(@(x)strcmp(x.TimingMode,'PERIODIC'),this.CodeInfo.TimingProperties);
                eventChannels=this.CodeInfo.TimingInternalIds(isPeriodic);

                this.CodeWriterObj.wComment('Create StepFunctions objects to run step functions concurrently.');
                this.CodeWriterObj.wLine('using StepFun = void (%s::*)();',modelClass);



                for ii=1:length(periodicFunctions)
                    outfun=periodicFunctions(ii);
                    name=outfun.Prototype.Name;
                    if isempty(eventChannels)||...
                        strcmp(this.XcpParams.AdaptiveAutosarXCPSlaveTransportLayer,'None')
                        this.CodeWriterObj.wLine('StepFunction<%s, StepFun> %s_sf{&%s, &%s::%s, araLog};',...
                        modelClass,name,modelClassObjectName,modelClass,name);
                    else
                        this.CodeWriterObj.wLine('StepFunction<%s, StepFun, %d> %s_sf{&%s, &%s::%s, araLog};',...
                        modelClass,eventChannels(ii),name,modelClassObjectName,modelClass,name);
                    end
                end

                tick_lcm=1;
                if~isempty(periodicFunctions)
                    baserate=this.getBaseRate(periodicFunctions);
                    this.CodeWriterObj.wComment('These tick variables represent how many base rate ');
                    this.CodeWriterObj.wComment('periods to wait before running a step function.  For ');
                    this.CodeWriterObj.wComment('example, step1_ticks=3 indicates every ');
                    this.CodeWriterObj.wComment('third base rate tick, we should run step1().');

                    for ii=length(periodicFunctions):-1:1
                        ticksPerCall=round(periodicFunctions(ii).Timing.SamplePeriod/baserate);


                        if(ticksPerCall>1)
                            this.CodeWriterObj.wLine('constexpr int32_t %s_ticks{%d};',periodicFunctions(ii).Prototype.Name,ticksPerCall);
                        end
                        ticks(ii)=ticksPerCall;
                    end
                    tick_lcm=this.lcms(ticks);
                    this.CodeWriterObj.wLine('constexpr double bRate{%f};',baserate);
                else
                    baserate=0.2000;


                    this.CodeWriterObj.wLine('constexpr double bRate{0.2000};');
                end

                this.CodeWriterObj.wComment('Start timer running at base rate.');
                this.CodeWriterObj.wLine('Timer stepTimer{bRate, mwSync::signal_handler, araLog};');
                this.CodeWriterObj.wLine('stepTimer.start();');

                this.CodeWriterObj.wComment('Once threads for the step functions have been created, ');
                this.CodeWriterObj.wComment('unblock signals on the main thread so we can receive ');
                this.CodeWriterObj.wComment('SIGRTMIN and SIGTERM');
                this.CodeWriterObj.wLine('unblock_signals(araLog);');

                this.CodeWriterObj.wLine('araLog.LogVerbose()<<"Starting Step function.";');

                if~isempty(periodicFunctions)
                    this.CodeWriterObj.wComment('Main loop, call step functions');
                    this.CodeWriterObj.wLine('constexpr int32_t tick_lcm{%d};',tick_lcm);
                    this.CodeWriterObj.wLine('int32_t tick{0};');
                    if~strcmp(this.XcpParams.AdaptiveAutosarXCPSlaveTransportLayer,'None')
                        this.CodeWriterObj.wLine('std::promise<void> stopXCPServerRunPromise;');
                        this.CodeWriterObj.wBlockStart('std::thread xcpServerRunThread([&](std::future<void> stopXCPServerRunFuture)');
                        this.CodeWriterObj.wBlockStart('while (stopXCPServerRunFuture.wait_for(std::chrono::milliseconds(10)) == std::future_status::timeout)');
                        this.CodeWriterObj.wLine('xcpSlaveRunBackground();');
                        this.CodeWriterObj.wBlockEnd();
                        this.CodeWriterObj.emitBlockEnd('',false,false);
                        this.CodeWriterObj.emitLine(', std::move(stopXCPServerRunPromise.get_future()));',false,false);
                    end
                    this.CodeWriterObj.wBlockStart('while(true)');
                    this.steploop(periodicFunctions,baserate);
                    this.CodeWriterObj.wBlockEnd();
                    if~strcmp(this.XcpParams.AdaptiveAutosarXCPSlaveTransportLayer,'None')
                        this.CodeWriterObj.wLine('stopXCPServerRunPromise.set_value();');
                        this.CodeWriterObj.wBlockStart('if(xcpServerRunThread.joinable())');
                        this.CodeWriterObj.wLine('xcpServerRunThread.join();');
                        this.CodeWriterObj.wBlockEnd();
                    end
                else

                    this.CodeWriterObj.wBlockStart('while(true)');
                    this.CodeWriterObj.wBlockStart('if (mwSync::halt_application)');
                    this.CodeWriterObj.wLine('break;');
                    this.CodeWriterObj.wBlockEnd();
                    this.CodeWriterObj.wBlockEnd();
                end

                for ii=1:length(periodicFunctions)
                    outfun=periodicFunctions(ii);
                    name=outfun.Prototype.Name;
                    this.CodeWriterObj.wLine('%s_sf.stop();',name);
                end
            end
            this.CodeWriterObj.wBlockEnd();


            this.CodeWriterObj.wBlockStart('if(bProceed)')
            this.CodeWriterObj.wBlockStart('try');
            if~strcmp(this.XcpParams.AdaptiveAutosarXCPSlaveTransportLayer,'None')
                this.CodeWriterObj.wLine('xcpSlaveReset();');
                this.CodeWriterObj.wLine('araLog.LogVerbose()<<"XCP Slave Reset successfully.";');
            end
            this.CodeWriterObj.wComment("Terminate Functions");
            for ii=1:length(this.CodeInfo.TerminateFunctions)
                termfun=this.CodeInfo.TerminateFunctions(ii);

                this.CodeWriterObj.wLine('%s.%s();',modelClassObjectName,termfun.Prototype.Name);
            end
            this.CodeWriterObj.wBlockMiddle('catch(std::exception const & e)');
            this.CodeWriterObj.wLine('araLog.LogError()<<"Unable to terminate: "<<e.what()<<".\n";');
            this.CodeWriterObj.wLine('bProceed = false;');
            this.CodeWriterObj.wBlockEnd();
            this.CodeWriterObj.wBlockEnd();


            this.CodeWriterObj.wBlockStart('try');
            this.writeReportExecutionState('kTerminating');

            this.CodeWriterObj.wLine('araLog.LogError()<<"Unable to report terminating state: ara::exec::ExecutionReturnType::kGeneralError.\n";');
            this.CodeWriterObj.wLine('bProceed = false;');
            this.CodeWriterObj.wBlockMiddle('else');
            this.CodeWriterObj.wLine('araLog.LogVerbose()<<"Exiting adaptive application.\n";');
            this.CodeWriterObj.wBlockEnd;
            this.CodeWriterObj.wBlockMiddle('catch(std::exception const & e)');
            this.CodeWriterObj.wLine('araLog.LogError()<<"Unable to report terminating state due to exception: "<<e.what()<<".\n";');
            this.CodeWriterObj.wLine('bProceed = false;');
            this.CodeWriterObj.wBlockEnd;

            this.CodeWriterObj.wLine('const ara::core::Result<void> deinitStatus{ara::core::Deinitialize()};');
            this.CodeWriterObj.wBlockStart('if(!deinitStatus.HasValue())');
            this.CodeWriterObj.wLine('bAraInitialized = false;');
            this.CodeWriterObj.wBlockEnd;

            this.CodeWriterObj.wBlockEnd;

            this.CodeWriterObj.wLine('constexpr int32_t APP_SUCCESS{0};');
            this.CodeWriterObj.wLine('constexpr int32_t APP_FAIL{1};');
            this.CodeWriterObj.wLine('return ((bAraInitialized && bProceed) ? APP_SUCCESS : APP_FAIL);');
        end

        function steploop(this,funs,baserate)
            this.CodeWriterObj.wBlockStart('if (mwSync::halt_application)');
            this.CodeWriterObj.wLine('break;');
            this.CodeWriterObj.wBlockEnd();

            this.CodeWriterObj.wBlockStart('if (sem_wait(&mwSync::baserate_tick) != SIG_RET_FAIL)');
            this.CodeWriterObj.wLine('tick = (tick+1) % tick_lcm;');


            for ii=1:length(funs)


                ticksPerCall=round(funs(ii).Timing.SamplePeriod/baserate);



                if(ticksPerCall>1)
                    this.CodeWriterObj.wBlockStart(sprintf('if ((tick %% %s_ticks) == 0)',funs(ii).Prototype.Name));
                end
                this.CodeWriterObj.wLine('%s_sf.step();',funs(ii).Prototype.Name);

                if(ticksPerCall>1)
                    this.CodeWriterObj.wBlockEnd();
                end
            end
            this.CodeWriterObj.wBlockEnd();
        end
    end

    methods(Static,Access=private)
        function result=lcms(rates)
            while(1<length(rates))
                rates=lcm(rates(1),rates(2:end));
            end
            result=rates;
        end

        function baseRate=getBaseRate(periodicFunctions)

            threshold=10^9;
            baseRate=periodicFunctions(1).Timing.SamplePeriod*threshold;
            for ii=2:numel(periodicFunctions)
                baseRate=gcd(baseRate,periodicFunctions(ii).Timing.SamplePeriod*threshold);
            end
            baseRate=baseRate/threshold;
        end
    end
end



