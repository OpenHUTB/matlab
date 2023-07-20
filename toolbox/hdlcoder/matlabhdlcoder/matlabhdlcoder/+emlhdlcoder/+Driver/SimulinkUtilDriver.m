classdef SimulinkUtilDriver<handle


    methods(Static)

        function formatBlockWithPorts(inPorts,outPorts,bH)

            numInPorts=length(inPorts);
            numOutPorts=length(outPorts);

            height=max(numInPorts,numOutPorts)*60;
            width=70;
            origPos=[105,40,105+width,40+height];
            set_param(bH,'Position',origPos);

            inPortSpacer=height/(numInPorts+1);
            inOrigPos=[origPos(1)-70,origPos(2)+inPortSpacer-20/2];
            for i=1:numInPorts
                left=inOrigPos(1);top=inOrigPos(2)+(i-1)*inPortSpacer;right=left+20;bottom=top+20;
                set_param(inPorts(i),'Position',[left,top,right,bottom]);
                add_line(get_param(bH,'Parent'),[get_param(inPorts(i),'name'),'/1'],[get_param(bH,'Name'),'/',num2str(i)],'autorouting','on');
            end
            outPortSpacer=height/(numOutPorts+1);
            outOrigPos=[origPos(3)+70,origPos(2)+outPortSpacer-20/2];
            for i=1:numOutPorts
                left=outOrigPos(1);top=outOrigPos(2)+(i-1)*outPortSpacer;right=left+20;bottom=top+20;
                set_param(outPorts(i),'Position',[left,top,right,bottom]);
                add_line(get_param(bH,'Parent'),[get_param(bH,'Name'),'/',num2str(i)],[get_param(outPorts(i),'name'),'/1'],'autorouting','on');
            end
        end

        function newSubsysPath=ctrl_G(parent,chips)%#ok<INUSD>

            preSubsys=find_system(parent,'SearchDepth',1,'BlockType','SubSystem','ReferenceBlock','');
            eval('Simulink.BlockDiagram.createSubSystem(chips)');
            postSubsys=find_system(parent,'SearchDepth',1,'BlockType','SubSystem','ReferenceBlock','');
            newSubsysPath=setdiff(postSubsys,preSubsys);
            newSubsysPath=newSubsysPath{:};
        end

        function transferMdlSettings(mdlName,hdlCfg)

            mdlSettings=struct('slParam','ResourceReport','hdlCfgParam','GenerateReport');
            mdlSettings(end+1)=struct('slParam','OptimizationReport','hdlCfgParam','GenerateReport');
            mdlSettings(end+1)=struct('slParam','Traceability','hdlCfgParam','GenerateReport');
            mdlSettings(end+1)=struct('slParam','TargetLanguage','hdlCfgParam','TargetLanguage');
            mdlSettings(end+1)=struct('slParam','GenerateHDLCode','hdlCfgParam','GenerateHDLCode');
            mdlSettings(end+1)=struct('slParam','GenerateHDLTestBench','hdlCfgParam','GenerateHDLTestBench');
            mdlSettings(end+1)=struct('slParam','ClockProcessPostfix','hdlCfgParam','ClockProcessPostfix');
            mdlSettings(end+1)=struct('slParam','ComplexImagPostfix','hdlCfgParam','ComplexImagPostfix');
            mdlSettings(end+1)=struct('slParam','ComplexRealPostfix','hdlCfgParam','ComplexRealPostfix');
            mdlSettings(end+1)=struct('slParam','DateComment','hdlCfgParam','DateComment');
            mdlSettings(end+1)=struct('slParam','EnablePrefix','hdlCfgParam','EnablePrefix');
            mdlSettings(end+1)=struct('slParam','EntityConflictPostfix','hdlCfgParam','EntityConflictPostfix');
            mdlSettings(end+1)=struct('slParam','PackagePostfix','hdlCfgParam','PackagePostfix');
            mdlSettings(end+1)=struct('slParam','PipelinePostfix','hdlCfgParam','PipelinePostfix');
            mdlSettings(end+1)=struct('slParam','ReservedWordPostfix','hdlCfgParam','ReservedWordPostfix');
            mdlSettings(end+1)=struct('slParam','UserComment','hdlCfgParam','UserComment');
            mdlSettings(end+1)=struct('slParam','VHDLFileExt','hdlCfgParam','VHDLFileExt');
            mdlSettings(end+1)=struct('slParam','VerilogFileExt','hdlCfgParam','VerilogFileExt');
            mdlSettings(end+1)=struct('slParam','ClockEnableInputPort','hdlCfgParam','ClockEnableInputPort');
            mdlSettings(end+1)=struct('slParam','ClockInputPort','hdlCfgParam','ClockInputPort');
            mdlSettings(end+1)=struct('slParam','ClockInputs','hdlCfgParam','ClockInputs');
            mdlSettings(end+1)=struct('slParam','Oversampling','hdlCfgParam','Oversampling');

            mdlSettings(end+1)=struct('slParam','ResetInputPort','hdlCfgParam','ResetInputPort ');
            mdlSettings(end+1)=struct('slParam','ResetType','hdlCfgParam','ResetType');
            mdlSettings(end+1)=struct('slParam','ClockEnableOutputPort','hdlCfgParam','ClockEnableOutputPort');


            mdlSettings(end+1)=struct('slParam','RAMMappingThreshold','hdlCfgParam','RAMThreshold');
            mdlSettings(end+1)=struct('slParam','ClockHighTime','hdlCfgParam','ClockHighTime');
            mdlSettings(end+1)=struct('slParam','ClockLowTime','hdlCfgParam','ClockLowTime');
            mdlSettings(end+1)=struct('slParam','ForceClock','hdlCfgParam','ForceClock');
            mdlSettings(end+1)=struct('slParam','ForceClockEnable','hdlCfgParam','ForceClockEnable');
            mdlSettings(end+1)=struct('slParam','ForceReset','hdlCfgParam','ForceReset');
            mdlSettings(end+1)=struct('slParam','HoldInputDataBetweenSamples','hdlCfgParam','HoldInputDataBetweenSamples');
            mdlSettings(end+1)=struct('slParam','HoldTime','hdlCfgParam','HoldTime');
            mdlSettings(end+1)=struct('slParam','IgnoreDataChecking','hdlCfgParam','IgnoreDataChecking');
            mdlSettings(end+1)=struct('slParam','InitializeTestBenchInputs','hdlCfgParam','InitializeTestBenchInputs');
            mdlSettings(end+1)=struct('slParam','MultifileTestBench','hdlCfgParam','MultifileTestBench');
            mdlSettings(end+1)=struct('slParam','ResetLength','hdlCfgParam','ResetLength');

            mdlSettings(end+1)=struct('slParam','TestBenchClockEnableDelay','hdlCfgParam','TestBenchClockEnableDelay');
            mdlSettings(end+1)=struct('slParam','TestBenchDataPostfix','hdlCfgParam','TestBenchDataPostfix');
            mdlSettings(end+1)=struct('slParam','TestBenchPostfix','hdlCfgParam','TestBenchPostfix');
            mdlSettings(end+1)=struct('slParam','TestBenchReferencePostFix','hdlCfgParam','TestReferencePostfix');
            mdlSettings(end+1)=struct('slParam','HDLCompileFilePostfix','hdlCfgParam','HDLCompileFilePostfix');
            mdlSettings(end+1)=struct('slParam','HDLCompileInit','hdlCfgParam','HDLCompileInit');
            mdlSettings(end+1)=struct('slParam','HDLCompileTerm','hdlCfgParam','HDLCompileTerm');
            mdlSettings(end+1)=struct('slParam','HDLCompileVHDLCmd','hdlCfgParam','HDLCompileVHDLCmd');
            mdlSettings(end+1)=struct('slParam','HDLCompileVerilogCmd','hdlCfgParam','HDLCompileVerilogCmd');
            mdlSettings(end+1)=struct('slParam','HDLSynthCmd','hdlCfgParam','HDLSynthCmd');
            mdlSettings(end+1)=struct('slParam','HDLSynthFilePostfix','hdlCfgParam','HDLSynthFilePostfix ');
            mdlSettings(end+1)=struct('slParam','HDLSynthInit','hdlCfgParam','HDLSynthInit');
            mdlSettings(end+1)=struct('slParam','HDLSynthTerm','hdlCfgParam','HDLSynthTerm');
            mdlSettings(end+1)=struct('slParam','ModulePrefix','hdlCfgParam','ModulePrefix');

            emlhdlcoder.Driver.SimulinkUtilDriver.transferHDLSettings(mdlName,mdlSettings,hdlCfg);
            if strcmpi(hdlCfg.ResetAssertedLevel,'ActiveHigh')
                val='Active-high';
            else
                val='Active-low';
            end
            hdlset_param(mdlName,'ResetAssertedLevel',val);

            if strcmpi(hdlCfg.InputType,'StdLogicVector')
                val='std_logic_vector';
            else
                val='signed/unsigned';
            end
            hdlset_param(mdlName,'InputType',val);

            if strcmpi(hdlCfg.OutputType,'SameAsInputType')
                val='Same as input type';
            elseif strcmpi(hdlCfg.OutputType,'StdLogicVector')
                val='std_logic_vector';
            else
                val='signed/unsigned';
            end
            hdlset_param(mdlName,'OutputType',val);

            if strcmpi(hdlCfg.ScalarizePorts,'off')
                val='off';
            elseif strcmpi(hdlCfg.ScalarizePorts,'dutlevel')
                val='dutlevel';
            else
                val='on';
            end
            hdlset_param(mdlName,'ScalarizePorts',val);

            if strcmpi(hdlCfg.SynthesisTool,'Altera QUARTUS II')
                val='Quartus';
            elseif strcmpi(hdlCfg.SynthesisTool,'Xilinx Vivado')
                val='Vivado';
            elseif strcmpi(hdlCfg.SynthesisTool,'Xilinx ISE')
                val='ISE';
            else
                val='None';
            end

            hdlset_param(mdlName,'HDLSynthTool',val);
        end

        function transferHDLSettings(target,settings,hdlCfg)
            for i=1:length(settings)

                paramName=deblank(settings(i).hdlCfgParam);
                paramVal=hdlCfg.(paramName);
                if islogical(paramVal)
                    if paramVal
                        val='on';
                    else
                        val='off';
                    end
                else
                    val=paramVal;
                end
                hdlset_param(target,settings(i).slParam,val);
            end
        end
    end
end
