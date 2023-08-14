classdef SchedulingServiceGenerator



    properties(Access=private)
modelName
buildDir
cw
cwHelper
schedulingInfo
    end

    methods

        function this=SchedulingServiceGenerator(modelName,...
            buildDir)
            narginchk(2,2);
            this.modelName=modelName;
            this.buildDir=buildDir;

            this.schedulingInfo=coder.internal.rte.SchedulingInfo(modelName);
        end

        function generateSDPMain(this)
            mainfile=this.getMainFile(this.modelName,this.buildDir);

            this.cw=rtw.connectivity.CodeWriter.create(...
            'callCBeautifier',true,...
            'filename',mainfile,...
            'append',false);
            this.cwHelper=rtw.connectivity.RTEMainUtils(this.cw);
            this.generateMain();
            this.cw.close;
        end
    end

    methods(Static)
        function mainfile=getMainFile(modelName,buildDir)
            targetLang=get_param(modelName,'TargetLang');
            switch targetLang
            case 'C'
                fileExt='c';
            case 'C++'

                fileExt='cpp';
            otherwise
                error('Unexpected TargetLang.')
            end
            mainfile=fullfile(buildDir,['ert_main.',fileExt]);
        end
    end


    methods(Access=private)
        function generateMain(this)


            this.writeDoc();
            this.writeHeaders();




            this.cw.wNewLine();
            this.writeRTOneStepFcn();

            this.cw.wNewLine();
            this.writeMainFcn();
        end

        function writeDoc(this)
            this.cw.wComment('Prerelease License - for engineering feedback and testing purposes only.');
            this.cw.wComment('RTE example main');
            this.cw.wComment(sprintf("Code generated for Simulink model '%s'",this.modelName));
            this.cw.wComment(['C/C++ source code generated on: ',...
            datestr(now,'ddd mmm dd HH:MM:SS yyyy')]);
        end

        function writeHeaders(this)

            systemHeaders="stdio.h";
            this.cwHelper.wHeaders(systemHeaders,'<>');

            modelHeader=convertCharsToStrings(this.schedulingInfo.ModelHeader);
            this.cwHelper.wHeaders(modelHeader,'""');

            codeDescriptor=coder.getCodeDescriptor(this.modelName);
            if coder.internal.rte.util.getNeedTimerService(codeDescriptor.getFullComponentInterface)
                this.cw.wLine('#include "services.h"');
                this.cw.wLine('#include "rte_private_timer.h"');
            end
        end

        function writeRTOneStepFcn(this)
            periodicOutputTasks=this.schedulingInfo.periodicOutputTasks;
            if isempty(periodicOutputTasks)
                return
            end

            fcnBanner=['Associating rt_OneStep with a real-time clock or interrupt ',...
            'service routine is what makes the generated code "real-time". ',...
            'The function rt_OneStep is always associated with the base rate of ',...
            'the model. Subrates are managed by the base rate from inside the ',...
            'generated code. Enabling/disabling interrupts and floating point ',...
            'context switches are target specific. This example code indicates ',...
            'where these should take place relative to executing the generated ',...
            'code step function. Overrun behavior should be tailored to your ',...
            'application needs. This example simply sets an error status in the ',...
            'real-time model and returns from rt_OneStep.'];
            this.cwHelper.wMultiLineComment(fcnBanner);


            fcnPrototype=this.cwHelper.getFcnPrototype('void','rt_OneStep',{'void'});


            this.cw.wLine('%s;',fcnPrototype);

            this.cw.wBlockStart(fcnPrototype);
            if this.schedulingInfo.isMultiTasking

                this.rtOneStepFcnBodyMultiTasking(periodicOutputTasks);
            else

                this.rtOneStepFcnBodySingleTasking(periodicOutputTasks);
            end
            this.cw.wBlockEnd();
        end

        function rtOneStepFcnBodySingleTasking(this,tasks)
            assert(numel(tasks)==1,'The number of tasks should be 1 for rtOneStepFcnBodySingleTasking.');
            this.cw.wLine('static boolean_T OverrunFlag = false;');
            this.cw.wComment('Disable interrupts here');
            this.cw.wNewLine();

            this.cw.wComment('Check for overrun');
            this.cw.wBlockStart('if (OverrunFlag)');
            if strcmp(this.schedulingInfo.SuppressErrorStatus,'off')
                this.cw.wLine('rtmSetErrorStatus(%s_M, "Overrun");',this.modelName);
            end
            this.cw.wLine('return;');
            this.cw.wBlockEnd('',false);

            this.cw.wLine('OverrunFlag = true;');
            this.cw.wComment('Save FPU context here (if necessary)');
            this.cw.wComment('Re-enable timer or interrupt here');
            this.cw.wNewLine();

            this.cw.wComment('Set model inputs here');
            this.cw.wNewLine();
            this.cw.wComment('Step the model');
            this.cw.wLine('%s;',tasks.codeInfoData.getFunctionCall);
            this.cw.wComment('Get model outputs here');

            this.cw.wNewLine();
            this.cw.wComment('Indicate task complete');
            this.cw.wLine('OverrunFlag = false;');
            this.cw.wComment('Disable interrupts here');
            this.cw.wComment('Restore FPU context here (if necessary)');
            this.cw.wComment('Enable interrupts here');
        end

        function rtOneStepFcnBodyMultiTasking(this,tasks)

            numTasks=numel(tasks);
            assert(numTasks>1,'The number of tasks should be greater than 1 for rtOneStepFcnBodyMultiTasking.');
            this.cw.wComment(sprintf('Model has %d tasks',numTasks));
            tmpVal=zeros(1,numTasks);
            tmpValStr=strjoin(string(tmpVal),', ');
            this.cw.wLine('static boolean_T OverrunFlags[%d] = {%s};',numTasks,tmpValStr);
            this.cw.wLine('static boolean_T eventFlags[%d] = {%s};',numTasks,tmpValStr);

            sampleTimes=zeros(1,numTasks);
            taskCntVal=zeros(1,numTasks);
            for i=1:numTasks
                stPeriod=tasks(i).codeInfoData.Timing.SamplePeriod;
                stOffset=tasks(i).codeInfoData.Timing.SampleOffset;
                basePeriod=tasks(1).codeInfoData.Timing.SamplePeriod;
                sampleTimes(i)=stPeriod;
                if stOffset~=0
                    numOffsetTicks=(stPeriod-stOffset)/basePeriod;
                    taskCntVal(i)=numOffsetTicks;
                end
            end
            sampleTimes=rescale(sampleTimes,1,max(sampleTimes)/min(sampleTimes));
            taskCntValStr=strjoin(string(taskCntVal),', ');
            this.cw.wLine('static int_T taskCounter[%d] = {%s};',numTasks,taskCntValStr);

            this.cw.wLine('int_T i;');

            this.cw.wComment('Disable interrupts here');
            this.cw.wNewLine();

            this.cw.wComment('Check base rate for overrun');
            this.cw.wBlockStart('if (OverrunFlags[0])');
            if strcmp(this.schedulingInfo.SuppressErrorStatus,'off')
                this.cw.wLine('rtmSetErrorStatus(%s_M, "Overrun");',this.modelName);
            end
            this.cw.wLine('return;');
            this.cw.wBlockEnd('',false);
            this.cw.wLine('OverrunFlags[0] = true;');

            this.cw.wComment('Save FPU context here (if necessary)');
            this.cw.wComment('Re-enable timer or interrupt here');
            this.cw.wNewLine();

            this.cwHelper.wMultiLineComment(['For a bare-board target (i.e., no operating system), ',...
            'the following code checks whether any subrate overruns, ',...
            'and also sets the rates that need to run this time step.']);

            this.cw.wBlockStart('for (i = 1; i < %d; i++)',numTasks);
            this.cw.wBlockStart('if (taskCounter[i] == 0)');
            this.cw.wBlockStart('if (eventFlags[i])');
            this.cw.wLine('OverrunFlags[0] = false;');
            this.cw.wLine('OverrunFlags[i] = true;');
            if strcmp(this.schedulingInfo.SuppressErrorStatus,'off')
                this.cw.wComment('Sampling too fast');
                this.cw.wLine('rtmSetErrorStatus(%s_M, "Overrun");',this.modelName);
            end
            this.cw.wBlockEnd('',false);
            this.cw.wLine('eventFlags[i] = true;');
            this.cw.wBlockEnd('',false);
            this.cw.wBlockEnd('',false);

            for i=1:numTasks-1
                this.cw.wLine('taskCounter[%d]++;',i);
                this.cw.wBlockStart('if (taskCounter[%d] == %d)',i,sampleTimes(i+1));
                this.cw.wLine('taskCounter[%d] = 0;',i);
                this.cw.wBlockEnd('',false);
            end

            this.cw.wComment('Set model inputs associated with base rate here');
            this.cw.wNewLine();
            this.cw.wComment('Step the model for base rate');
            this.cw.wLine('%s;',tasks(1).codeInfoData.getFunctionCall);
            this.cw.wComment('Get model outputs here');
            this.cw.wNewLine();

            this.cw.wComment('Indicate task for base rate complete');
            this.cw.wLine('OverrunFlags[0] = false;');

            this.cw.wComment('Step the model for subrates');
            this.cw.wBlockStart('for (i = 1; i < %d; i++)',numTasks);
            this.cw.wComment('If task "i" is running, do not run any lower priority task');
            this.cw.wBlockStart('if (OverrunFlags[i])');
            this.cw.wLine('return;');
            this.cw.wBlockEnd('',false);

            this.cw.wBlockStart('if (eventFlags[i])');
            this.cw.wLine('OverrunFlags[i] = true;');
            this.cw.wComment('Set model inputs associated with subrates here');

            this.cw.wComment('Step the model for subrate "i"');
            this.cw.wBlockStart('switch (i)');
            for i=1:numTasks-1
                this.cw.wLine('case %d: ',i);
                this.cw.wLine(' %s;',tasks(i+1).codeInfoData.getFunctionCall);
                this.cw.wLine(' break;');
            end
            this.cw.wLine('default:');
            this.cw.wLine(' break;');
            this.cw.wBlockEnd('end of switch',false);

            this.cw.wComment('Indicate task complete for sample time "i"');
            this.cw.wLine('OverrunFlags[i] = false;');
            this.cw.wLine('eventFlags[i] = false;');

            this.cw.wBlockEnd('end of if',false);
            this.cw.wBlockEnd('end of for',false);

            this.cw.wComment('Disable interrupts here');
            this.cw.wComment('Restore FPU context here (if necessary)');
            this.cw.wComment('Enable interrupts here');
        end

        function writeMainFcn(this)
            fcnBanner=['The example main function illustrates what is required by your application. ',...
            'Attaching rt_OneStep to a real-time clock is target specific. ',...
            'This example illustrates how you do this relative to initializing the model.'];
            this.cwHelper.wMultiLineComment(fcnBanner);

            this.cw.wBlockStart('int_T main(int_T argc, const char *argv[])');
            this.cw.wComment('Unused arguments')
            this.cw.wLine('(void)(argc);');
            this.cw.wLine('(void)(argv);');

            initTasks=this.schedulingInfo.initTasks;

            this.cw.wNewLine();
            this.cw.wComment('Initialize model');
            this.cw.wLine('%s;',initTasks.codeInfoData.getFunctionCall);


            this.cw.wLine('printf("Warning: The simulation will run forever. "');
            tmpStr="Generated ERT main won't simulate model step behavior.";
            this.cw.wLine('"%s"',tmpStr);
            tmpStr="To change this behavior select the 'MAT-file logging' option.\n";
            this.cw.wLine('"%s");',tmpStr);
            this.cw.wLine('fflush((NULL));');

            periodicOutputTasks=this.schedulingInfo.periodicOutputTasks;
            this.cw.wBlockStart('while(%s)',this.getStopStr());
            this.cw.wComment('Perform application tasks here');
            if~isempty(periodicOutputTasks)
                this.cwHelper.wMultiLineComment(sprintf(...
                ['Attach rt_OneStep to a timer or interrupt service routine ',...
                'with period %d seconds (base sample time) here. The ',...
                'call syntax for rt_OneStep is rt_OneStep();'],...
                periodicOutputTasks(1).codeInfoData.Timing.SamplePeriod));
                this.cw.wLine('rt_OneStep();');
            end
            this.cw.wBlockEnd('end of while',false);


            outputTasks=this.schedulingInfo.outputTasks;
            if numel(outputTasks)>numel(periodicOutputTasks)
                for task=outputTasks
                    tMode=task.codeInfoData.Timing.TimingMode;
                    if tMode~="PERIODIC"
                        this.cw.wComment("Unscheduled "+lower(string(tMode))+" task: "+task.codeInfoData.getFunctionCall);
                    end
                end
            end

            termTasks=this.schedulingInfo.termTasks;
            if~isempty(termTasks)
                this.cw.wNewLine();
                this.cw.wComment('Terminate model');
                this.cw.wLine('%s;',termTasks.codeInfoData.getFunctionCall);
            end

            this.cw.wLine('return 0;')
            this.cw.wBlockEnd('end of main');
        end

        function stopStr=getStopStr(this)
            stopList={};
            if strcmp(this.schedulingInfo.SuppressErrorStatus,'off')
                stopList{end+1}=sprintf('rtmGetErrorStatus(%s_M) == (NULL)',this.modelName);
            end


            if~isempty(find_system(this.modelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FirstResultOnly','on','BlockType','Stop'))
                stopList{end+1}=sprintf('!rtmGetStopRequested(%s_M)',this.modelName);
            end
            stopStr=strjoin(stopList,' && ');
            if isempty(stopStr)
                stopStr='1';
            end
        end
    end
end
