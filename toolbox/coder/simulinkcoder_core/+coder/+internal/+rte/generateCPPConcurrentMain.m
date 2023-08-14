

function generateCPPConcurrentMain(h,modelName,buildDir,overrideMain)
    narginchk(3,4);
    if nargin<4
        overrideMain=true;
    end

    mainfile=coder.internal.rte.SchedulingServiceGenerator.getMainFile(modelName,buildDir);


    if isfile(mainfile)&&~overrideMain

        return
    end


    generateConcurrentMain(h,modelName);

end

function generateConcurrentMain(h,modelName)


    codeDescriptor=coder.getCodeDescriptor(modelName);
    bdir=codeDescriptor.BuildDir;

    copyfile(fullfile(matlabroot,'toolbox','coder','simulinkcoder','src','executor','Executor.hpp'),bdir);
    copyfile(fullfile(matlabroot,'toolbox','coder','simulinkcoder','src','executor','Timer.hpp'),bdir);
    copyfile(fullfile(matlabroot,'toolbox','coder','simulinkcoder','src','executor','WorkerPool.hpp'),bdir);

    h.BuildInfo.addIncludeFiles('Executor.hpp',bdir,'Static');

    reportInfo=rtw.report.ReportInfo.instance(modelName);

    [p,f,e]=fileparts(fullfile(bdir,'Executor.hpp'));

    reportInfo.addFileInfo([f,e],'main','header',p);

    cppfile=fullfile(bdir,'ert_main.cpp');
    writer=rtw.connectivity.CodeWriter.create(...
    'callCBeautifier',false,...
    'filename',cppfile,...
    'append',false);

    writer.wComment(sprintf('Code generated for Simulink model %s',codeDescriptor.ModelName));
    writer.wComment(sprintf('Code generated on %s',datestr(now,'ddd mmm dd HH:MM:SS yyyy')));

    schedulingInfo=coder.internal.rte.SchedulingInfo(modelName);
    include_headers(writer,schedulingInfo);
    if slfeature('TestingCPP11ConcurrentMain')
        addTestHarness(writer);
    end
    globalVariables(writer,schedulingInfo);

    writer.wComment('main() handles the following:');
    writer.wComment(' - Instantiate the model object and owns its memory.');
    writer.wComment(' - Call the model initialize and terminate functions.');
    writer.wComment(' - Register tasks and add them to the scheduler');
    writer.wBlockStart('int main()');

    mainbody(writer,schedulingInfo);
    writer.wBlockEnd();

    writer.close;


    if coder.internal.clang.Utils.isClangToolingAvailable()
        coder.internal.clang.CodeFormat.runFormat({cppfile});
    end
end

function addTestHarness(writer)
    writer.wLine('#include <sstream>');
    writer.wLine('#include <fstream>');
    writer.wLine('std::mutex logMutex;');
    writer.wLine('std::ofstream toFile("TimeStamp.txt\0");');
    writer.wNewLine;
    writer.wComment('Log message for testing.');
    writer.wBlockStart('void logMessage(const std::string& msg, const std::string& id)');
    writer.wLine('std::unique_lock<std::mutex> lk(logMutex);');
    writer.wLine('std::stringstream log;');
    writer.wLine('log << msg << ",";');
    writer.wLine('log << id << ",";');
    writer.wLine('log << std::chrono::duration_cast<std::chrono::microseconds>');
    writer.wLine(' (std::chrono::system_clock::now().time_since_epoch()).count();');
    writer.wLine('log << std::endl;');
    writer.wLine('toFile << log.str();');
    writer.wBlockEnd();
end

function include_headers(writer,schedulingInfo)
    writer.wLine('#include "Executor.hpp"');
    arrayfun(@(header)writer.wLine('#include "%s"',header),schedulingInfo.FunctionHeaders);
end

function globalVariables(writer,schedulingInfo)
    if~isempty(schedulingInfo.ModelClassName)
        writer.wLine('%s %s;',schedulingInfo.ModelClassName,schedulingInfo.ModelClassObjectName);
    end
end

function mainbody(writer,schedulingInfo)
    writer.wNewLine;
    if~isempty(schedulingInfo.ModelClassObjectName)
        modelClassObjectName=schedulingInfo.ModelClassObjectName;
    else
        modelClassObjectName='model';
        writer.wLine('%sModelClass %s;',schedulingInfo.ModelName,modelClassObjectName);
    end

    writer.wComment('These rate variables represent how many base rate ');
    writer.wComment('periods to wait before running a step function.');
    if~isempty(schedulingInfo.periodicOutputTasks)
        baserate=schedulingInfo.getBaseRate();
        writer.wLine('double const baserate = %g;',baserate);
    else
        baserate=0.2;


        writer.wLine('double const baserate = %g;',baserate);
    end

    writer.wComment('Initialize Function');
    arrayfun(@(task)writer.wLine(sprintf('%s.%s();',modelClassObjectName,task.codeInfoData.Prototype.Name)),schedulingInfo.initTasks);

    if~isempty(schedulingInfo.asyncOutputTasks)
        writer.wComment('Asynchronous tasks found in the model.');
        writer.wComment('To schedule these tasks, manually call the functions commented out below: ');
        arrayfun(@(task)writer.wComment(sprintf('%s();',task.codeInfoData.Prototype.Name)),schedulingInfo.asyncOutputTasks);
    end

    if~isempty(schedulingInfo.unknownTasks)
        writer.wComment('Some unhandled tasks were found in the model.');
        writer.wComment('To schedule these tasks, manually call the functions commented out below: ');
        arrayfun(@(taskName)writer.wComment(sprintf('%s();',taskName)),schedulingInfo.unknownTasks);
    end

    writer.wNewLine();

    writer.wComment('Create scheduler and add tasks');
    writer.wLine('platform::runtime::Executor executor;',schedulingInfo.ModelClassName);
    writer.wLine('executor.setBaseRateInSeconds(std::chrono::duration<double>(baserate));');

    writer.wComment('Add periodic tasks');
    for ii=1:length(schedulingInfo.periodicOutputTasks)
        outFcnName=schedulingInfo.periodicOutputTasks(ii).codeInfoData.Prototype.Name;
        if slfeature('TestingCPP11ConcurrentMain')

            beginMsg=sprintf('logMessage("S", "%s")',outFcnName);
            endMsg=sprintf('logMessage("E", "%s")',outFcnName);
        end

        tick=schedulingInfo.Ticks(ii);
        offset=schedulingInfo.TickOffsets(ii);

        if offset>0
            if slfeature('TestingCPP11ConcurrentMain')
                writer.wLine('executor.addPeriodicEvent([](){ %s; %s.%s(); %s; }, %d, %d);',...
                beginMsg,modelClassObjectName,outFcnName,endMsg,tick,offset);
            else
                writer.wLine('executor.addPeriodicEvent([](){ %s.%s(); }, %d, %d);',...
                modelClassObjectName,outFcnName,tick,offset);
            end
        else
            if slfeature('TestingCPP11ConcurrentMain')
                writer.wLine('executor.addPeriodicEvent([](){ %s; %s.%s(); %s; }, %d);',...
                beginMsg,modelClassObjectName,outFcnName,endMsg,tick);
            else
                writer.wLine('executor.addPeriodicEvent([](){ %s.%s(); }, %d);',...
                modelClassObjectName,outFcnName,tick);
            end
        end
    end

    writer.wNewLine();

    if~isempty(schedulingInfo.periodicOutputTasks)
        writer.wComment('Run model');

        stopTime=str2double(schedulingInfo.StopTime);
        if isnan(stopTime)||isinf(stopTime)
            writer.wLine('executor.run();');
        elseif floor(stopTime/baserate)==0.0
            writer.wLine('// The StopTime (%g) is less than the base rate (%g).',stopTime,baserate);
            writer.wLine('// Increase the StopTime to enable execution.');
            writer.wNewLine();
            writer.wLine('// executor.run();');
        else

            writer.wLine('executor.run(%g);',floor(stopTime/baserate));
        end
        writer.wNewLine();

    end

    writer.wComment("Terminate Function");
    arrayfun(@(task)writer.wLine(sprintf('%s.%s();',modelClassObjectName,task.codeInfoData.Prototype.Name)),schedulingInfo.termTasks);

    writer.wLine('return EXIT_SUCCESS;');
end
