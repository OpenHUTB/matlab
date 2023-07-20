classdef ExecutorMainWriter<handle







    properties(Access=protected)
        CodeWriterObj;
        CodeInfo;
        XcpParams;
        ExecutionReporter;
    end

    methods(Static,Access=public)
        function mainWriterObj=create(codeInfo,schemaVer,bdir,writerObj,xcpParams)






            if nargin<5
                xcpParams=struct('AdaptiveAutosarXCPSlaveTransportLayer','None');
            end


            shouldCallCBeautifier=~coder.internal.clang.Utils.isClangToolingAvailable();

            if(nargin>3)&&~isempty(writerObj)
                codeWriterObj=rtw.connectivity.CodeWriter.create(...
                'callCBeautifier',shouldCallCBeautifier,...
                'writerObject',writerObj);
            else
                cppfile=fullfile(bdir,'main.cpp');
                codeWriterObj=rtw.connectivity.CodeWriter.create(...
                'callCBeautifier',shouldCallCBeautifier,...
                'filename',cppfile,...
                'append',false);
            end

            mainWriterObj=autosar.internal.adaptive.main.ExecutorMainWriter(codeWriterObj,codeInfo,xcpParams);
            if strcmp(schemaVer,'R18-10')
                mainWriterObj.ExecutionReporter=autosar.internal.adaptive.main.Writer1810(codeWriterObj,codeInfo,xcpParams);
            elseif strcmp(schemaVer,'R19-03')
                mainWriterObj.ExecutionReporter=autosar.internal.adaptive.main.Writer1903(codeWriterObj,codeInfo,xcpParams);
            elseif strcmp(schemaVer,'R19-11')
                mainWriterObj.ExecutionReporter=autosar.internal.adaptive.main.Writer1911(codeWriterObj,codeInfo,xcpParams);
            elseif strcmp(schemaVer,'R20-11')
                mainWriterObj.ExecutionReporter=autosar.internal.adaptive.main.Writer2011(codeWriterObj,codeInfo,xcpParams);
            else
                assert(false,'AUTOSAR Schema greater than R20-11 is not supported yet');
            end
        end
    end
    methods(Access=public)
        function this=ExecutorMainWriter(codeWriterObj,codeInfo,xcpParams)
            this.CodeWriterObj=codeWriterObj;
            this.CodeInfo=codeInfo;
            this.XcpParams=xcpParams;
        end

        function generate(this)
            schedulingInfo=coder.internal.rte.SchedulingInfo(this.CodeInfo.Name);



            this.CodeWriterObj.wComment(sprintf('Code generated for Simulink model %s',this.CodeInfo.Name));
            this.CodeWriterObj.wComment(sprintf('Generated on %s',date));
            this.CodeWriterObj.wNewLine;
            this.CodeWriterObj.wNewLine;

            this.IncludeHeaders(schedulingInfo);

            if~strcmp(this.XcpParams.AdaptiveAutosarXCPSlaveTransportLayer,'None')
                this.CodeWriterObj.wNewLine();
                this.CodeWriterObj.wBlockStart('void xcpEvent(int eventID)');
                this.CodeWriterObj.wLine('#ifdef XCP_SUPPORT_ADAPTIVE_AUTOSAR');
                this.CodeWriterObj.wLine('xcpSlaveEvent(eventID);');
                this.CodeWriterObj.wLine('#endif');
                this.CodeWriterObj.wBlockEnd();
                this.CodeWriterObj.wNewLine();

                this.CodeWriterObj.wBlockStart('void xcpRunBackground(std::future<void>& stopXCPServerRunFuture)');
                this.CodeWriterObj.wBlockStart('while (stopXCPServerRunFuture.wait_for(std::chrono::milliseconds(10)) == std::future_status::timeout)');
                this.CodeWriterObj.wLine('xcpSlaveRunBackground();');
                this.CodeWriterObj.wBlockEnd();
                this.CodeWriterObj.wBlockEnd();
                this.CodeWriterObj.wNewLine();
            end

            this.CodeWriterObj.wNewLine;
            this.CodeWriterObj.wComment('main() handles the following:');
            this.CodeWriterObj.wComment(' - Instantiates the model object and owns its memory.');
            this.CodeWriterObj.wComment(' - Reports the Execution state to ARA');
            this.CodeWriterObj.wComment(' - Calls the model''s initialize and terminate functions.');
            this.CodeWriterObj.wComment(' - Creates an executor instance to schedule the periodic step functions');
            this.CodeWriterObj.wComment('      - A timer that is set to the base rate is created in the executor');
            this.CodeWriterObj.wComment('      - The step functions are added to the executor and run');
            this.CodeWriterObj.wComment('        based on their sample periods');

            this.CodeWriterObj.wBlockStart('int32_t main()');
            this.MainBody(schedulingInfo);
            this.CodeWriterObj.wBlockEnd();

            this.CodeWriterObj.close;

            if coder.internal.clang.Utils.isClangToolingAvailable()
                coder.internal.clang.CodeFormat.runFormat({'main.cpp'});
            end

        end
    end

    methods(Access=private)

        function IncludeHeaders(this,schedulingInfo)
            this.CodeWriterObj.wLine('#include <cstdint>');
            this.CodeWriterObj.wLine('#include <exception>');
            this.CodeWriterObj.wLine('#include "PosixExecutor.hpp"');
            this.CodeWriterObj.wLine('#include <ara/core/initialization.h>');
            this.CodeWriterObj.wLine('#include <ara/core/result.h>');
            this.CodeWriterObj.wLine('#include <ara/exec/execution_client.h>');
            this.ExecutionReporter.includeLogHeaders();

            if~strcmp(this.XcpParams.AdaptiveAutosarXCPSlaveTransportLayer,'None')
                this.CodeWriterObj.wLine('#ifdef __cplusplus');
                this.CodeWriterObj.wLine('extern "C" {');
                this.CodeWriterObj.wLine('#endif');
                this.CodeWriterObj.wLine('#include "xcp_slave.h"');
                this.CodeWriterObj.wLine('#ifdef __cplusplus');
                this.CodeWriterObj.wLine('}');
                this.CodeWriterObj.wLine('#endif');
            end

            arrayfun(@(header)this.CodeWriterObj.wLine('#include "%s"',header),schedulingInfo.FunctionHeaders);



            if~isempty(schedulingInfo.ModelClassObjectName)&&...
                ~strcmp(this.XcpParams.AdaptiveAutosarXCPSlaveTransportLayer,'None')
                this.CodeWriterObj.wLine('%s %s;',schedulingInfo.ModelClassName,schedulingInfo.ModelClassObjectName);
            end
        end

        function MainBody(this,schedulingInfo)

            this.CodeWriterObj.wComment('Used to control the flow in case of error in any api''s used.');
            this.CodeWriterObj.wLine('bool bProceed{true};');
            this.CodeWriterObj.wComment('Used to decide whether ara function clusters has been initialized.');
            this.CodeWriterObj.wLine('bool bAraInitialized{true};');

            this.CodeWriterObj.wComment('ara function cluster init.');
            this.CodeWriterObj.wLine('const ara::core::Result<void> initStatus{ara::core::Initialize()};')
            this.CodeWriterObj.wNewLine;

            this.CodeWriterObj.wBlockStart('if(!initStatus.HasValue())');
            this.CodeWriterObj.wLine('bProceed =  false;');
            this.CodeWriterObj.wLine('bAraInitialized = false;');
            this.CodeWriterObj.wBlockEnd();

            this.CodeWriterObj.wNewLine;
            this.CodeWriterObj.wBlockStart('if(bAraInitialized)');
            this.CodeWriterObj.wLine('ara::log::Logger & araLog{ara::log::CreateLogger("%s", "Logger for %s''s main function.")};',...
            this.CodeInfo.Name,this.CodeInfo.Name);
            this.CodeWriterObj.wNewLine;

            this.CodeWriterObj.wComment('Report Execution state');
            this.CodeWriterObj.wLine('ara::exec::ExecutionClient exec_client;');


            this.CodeWriterObj.wBlockStart('try');
            this.ExecutionReporter.writeReportExecutionState('kRunning');
            this.CodeWriterObj.wLine('araLog.LogError()<<"Unable to report running state: ara::exec::ExecutionReturnType::kGeneralError.\n";');
            this.CodeWriterObj.wLine('bProceed = false;');
            this.CodeWriterObj.wBlockMiddle('else');
            this.CodeWriterObj.wLine('araLog.LogVerbose()<<"Adaptive application entering running state.";');
            this.CodeWriterObj.wBlockEnd;
            this.CodeWriterObj.wBlockMiddle('catch(std::exception const & e)');
            this.CodeWriterObj.wLine('araLog.LogError()<<"Unable to report running state due to exception: "<<e.what()<<".\n";');
            this.CodeWriterObj.wLine('bProceed = false;');
            this.CodeWriterObj.wBlockEnd;
            this.CodeWriterObj.wNewLine;



            if~isempty(schedulingInfo.ModelClassObjectName)
                modelClassObjectName=schedulingInfo.ModelClassObjectName;
                if strcmp(this.XcpParams.AdaptiveAutosarXCPSlaveTransportLayer,'None')
                    this.CodeWriterObj.wLine('%s %s;',schedulingInfo.ModelClassName,modelClassObjectName);
                end
            else
                modelClassObjectName='model';
                this.CodeWriterObj.wLine('%sModelClass %s;',schedulingInfo.ModelClassName,modelClassObjectName);
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

            arrayfun(@(task)this.CodeWriterObj.wLine(sprintf('%s.%s();',modelClassObjectName,task.codeInfoData.Prototype.Name)),schedulingInfo.initTasks);

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
            this.CodeWriterObj.wNewLine;


            this.CodeWriterObj.wBlockStart('if(bProceed)')

            if~isempty(schedulingInfo.asyncOutputTasks)
                this.CodeWriterObj.wComment('Simulink supports scheduling Adaptive AUTOSAR tasks');
                this.CodeWriterObj.wComment('periodically, but some asynchronous tasks were found');
                this.CodeWriterObj.wComment('in the model.  To schedule these tasks, manually call the');
                this.CodeWriterObj.wComment('functions commented out below:');
                arrayfun(@(task)this.CodeWriterObj.wComment(sprintf('%s();',task.codeInfoData.Prototype.Name)),schedulingInfo.asyncOutputTasks);
                this.CodeWriterObj.wNewLine;
            end


            if~isempty(schedulingInfo.unknownTasks)
                this.CodeWriterObj.wComment('Simulink supports scheduling Adaptive AUTOSAR tasks');
                this.CodeWriterObj.wComment('periodically, but some unhandled tasks were found');
                this.CodeWriterObj.wComment('in the model.  To schedule these tasks, manually call the');
                this.CodeWriterObj.wComment('functions commented out below:');
                arrayfun(@(taskName)this.CodeWriterObj.wComment(sprintf('%s();',taskName)),schedulingInfo.unknownTasks);
                this.CodeWriterObj.wNewLine;
            end






            isPeriodic=arrayfun(@(x)strcmp(x.TimingMode,'PERIODIC'),schedulingInfo.TimingProperties);
            eventChannels=this.CodeInfo.TimingInternalIds(isPeriodic);



            if~isempty(schedulingInfo.periodicOutputTasks)||~isempty(schedulingInfo.asyncOutputTasks)

                this.CodeWriterObj.wComment('Create an executor instance to schedule the periodic step functions');
                this.CodeWriterObj.wComment('Whenever the period of a step function passes, the executor');
                this.CodeWriterObj.wComment('schedules that step function to be executed on a thread.');
                this.CodeWriterObj.wLine('platform::runtime::Executor fcnExecutor;');

                baseRate=0.2;
                if~isempty(schedulingInfo.periodicOutputTasks)
                    baseRate=schedulingInfo.getBaseRate();
                end

                this.CodeWriterObj.wNewLine;
                this.CodeWriterObj.wComment('Base rate is the time unit of a tick');
                this.CodeWriterObj.wLine('fcnExecutor.setBaseRateInSeconds(std::chrono::duration<double>(%f));',baseRate);

                this.CodeWriterObj.wNewLine;
                if~isempty(schedulingInfo.periodicOutputTasks)
                    this.CodeWriterObj.wComment('Register periodic step functions in the executor.');
                end
                for ii=1:length(schedulingInfo.periodicOutputTasks)
                    name=schedulingInfo.periodicOutputTasks(ii).codeInfoData.Prototype.Name;
                    if isempty(eventChannels)||...
                        strcmp(this.XcpParams.AdaptiveAutosarXCPSlaveTransportLayer,'None')
                        this.CodeWriterObj.wLine('fcnExecutor.addPeriodicEvent([&%s, &araLog](){ try{ %s.%s(); } catch(std::exception const &e) { araLog.LogError() << "Error executing step: " << e.what(); }}, %d);',...
                        modelClassObjectName,modelClassObjectName,name,schedulingInfo.Ticks(ii));
                    else
                        this.CodeWriterObj.wLine('fcnExecutor.addPeriodicEvent([&araLog](){ try{ %s.%s(); xcpEvent(%d); } catch(std::exception const & e){ araLog.LogError() << "Error executing step: " << e.what(); }}, %d);',...
                        modelClassObjectName,name,eventChannels(ii),schedulingInfo.Ticks(ii));
                    end
                end

                if~strcmp(this.XcpParams.AdaptiveAutosarXCPSlaveTransportLayer,'None')
                    this.CodeWriterObj.wNewLine();
                    this.CodeWriterObj.wLine('std::promise<void> stopXCPServerRunPromise;');
                    this.CodeWriterObj.wLine('auto stopXCPServerRunFuture = stopXCPServerRunPromise.get_future();');
                    this.CodeWriterObj.wLine('fcnExecutor.addEvent([&stopXCPServerRunFuture](){ xcpRunBackground(stopXCPServerRunFuture); return false; }, nullptr, [&stopXCPServerRunPromise](){ stopXCPServerRunPromise.set_value(); });');
                    this.CodeWriterObj.wNewLine();
                end

                this.CodeWriterObj.wNewLine;
                this.CodeWriterObj.wLine('araLog.LogVerbose()<<"Starting Step function.";');
                this.CodeWriterObj.wLine('fcnExecutor.run<ara::log::Logger>(araLog);');
            end
            this.CodeWriterObj.wBlockEnd();


            this.CodeWriterObj.wNewLine;

            this.CodeWriterObj.wBlockStart('if(bProceed)')
            this.CodeWriterObj.wBlockStart('try');
            if~strcmp(this.XcpParams.AdaptiveAutosarXCPSlaveTransportLayer,'None')
                this.CodeWriterObj.wLine('xcpSlaveReset();');
                this.CodeWriterObj.wLine('araLog.LogVerbose()<<"XCP Slave Reset successfully.";');
            end

            this.CodeWriterObj.wComment("Terminate Functions");
            arrayfun(@(task)this.CodeWriterObj.wLine(sprintf('%s.%s();',modelClassObjectName,task.codeInfoData.Prototype.Name)),schedulingInfo.termTasks);

            this.CodeWriterObj.wBlockMiddle('catch(std::exception const & e)');
            this.CodeWriterObj.wLine('araLog.LogError()<<"Unable to terminate: "<<e.what()<<".\n";');
            this.CodeWriterObj.wLine('bProceed = false;');
            this.CodeWriterObj.wBlockEnd();
            this.CodeWriterObj.wBlockEnd();
            this.CodeWriterObj.wNewLine;


            this.CodeWriterObj.wBlockStart('try');
            this.ExecutionReporter.writeReportExecutionState('kTerminating');

            this.CodeWriterObj.wLine('araLog.LogError()<<"Unable to report terminating state: ara::exec::ExecutionReturnType::kGeneralError.\n";');
            this.CodeWriterObj.wLine('bProceed = false;');
            this.CodeWriterObj.wBlockMiddle('else');
            this.CodeWriterObj.wLine('araLog.LogVerbose()<<"Exiting adaptive application.\n";');
            this.CodeWriterObj.wBlockEnd;
            this.CodeWriterObj.wBlockMiddle('catch(std::exception const & e)');
            this.CodeWriterObj.wLine('araLog.LogError()<<"Unable to report terminating state due to exception: "<<e.what()<<".\n";');
            this.CodeWriterObj.wLine('bProceed = false;');
            this.CodeWriterObj.wBlockEnd;
            this.CodeWriterObj.wNewLine;

            this.CodeWriterObj.wLine('const ara::core::Result<void> deinitStatus{ara::core::Deinitialize()};');
            this.CodeWriterObj.wBlockStart('if(!deinitStatus.HasValue())');
            this.CodeWriterObj.wLine('bAraInitialized = false;');
            this.CodeWriterObj.wBlockEnd;

            this.CodeWriterObj.wBlockEnd;

            this.CodeWriterObj.wNewLine;
            this.CodeWriterObj.wLine('constexpr int32_t APP_SUCCESS{0};');
            this.CodeWriterObj.wLine('constexpr int32_t APP_FAIL{1};');
            this.CodeWriterObj.wLine('return ((bAraInitialized && bProceed) ? APP_SUCCESS : APP_FAIL);');
        end

    end
end



