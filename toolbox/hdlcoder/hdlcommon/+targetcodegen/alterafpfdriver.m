



classdef alterafpfdriver<targetcodegen.basedriver
    properties(SetAccess=protected,GetAccess=protected)
    end

    properties(Constant=true)

        targetCompIPName={...
        'ip_none',...
        'ip_add',...
        'ip_mul',...
        'ip_div',...
        'ip_conv',...
        'ip_relop',...
        'ip_abs',...
        'ip_sqrt',...
        'ip_rsqrt',...
        'ip_recip',...
        'ip_exp',...
        'ip_log',...
        'ip_sin',...
        'ip_cos',...
        'ip_multadd',...
        };
    end

    methods
        function obj=alterafpfdriver(varargin)
            obj@targetcodegen.basedriver(varargin{:});
        end






        function flag=isCompCompatible(~,c)
            flag=c.getSupportAlteraMegaFunctions;
        end


        function replaceWithTargetFunctions(this,p,hdldriver)


            this.createInventoryAndReplaceWithTargetFunctions(p,hdldriver);
            if(this.config.LibrarySettings.InitializeIPPipelinesToZero)
                p.addPipelineInitialSequenceLogicForMegaFunction();
            else
                hdldriver.addCheckCurrentDriver('Warning',message('hdlcommon:targetcodegen:InitializeIPPipelines'));
            end
        end


        function replaceWithInstantiationComp(this,ntk,c)
            replaceWithALTERAFPF(this,ntk,c);
        end


        function latency=resolveLatencyFromFrequency(this,c)
            latency=0;
            if(strcmpi(c.ClassName,'data_conv_comp')&&isEqual(c.PirInputSignals.Type,c.PirOutputSignals.Type))
                return;
            end

            latency=this.getCustomizedLatency(c);
            if(latency~=-1)
                c.setTargetCodeGenerationLatency(latency);
                return;
            else
                latencyFreq=this.getDesiredFrequence();
            end
            ntk=[];
            isFreqDriven=true;

            [~,status]=this.generateIP(ntk,c,c.ClassName,latencyFreq,isFreqDriven);
            if(isempty(status))
                latency=0;
                return;
            end

            if(status.status~=0)
                error(message('hdlcommon:targetcodegen:CannotArchieveTargetFrequency',latencyFreq));
            end
            latency=status.achievedLatency;
            c.setTargetCodeGenerationLatency(latency);
        end


        function latency=resolveLatencyForComp(this,c)
            latency=this.resolveLatencyFromFrequency(c);
        end

        function latency=getDefaultLatency(this,targetIPType,targetCompDataType,~)
            if strcmpi(targetIPType,'UMINUS')
                latency=0;
                return;
            end
            assert(strcmpi(class(this.config.m_strategy),'fpconfig.FrequencyDrivenStrategy'));
            ipSettings=this.config.IPConfig.getIPSettings(targetIPType,targetCompDataType);
            if(isempty(ipSettings))
                latency=-1;
            else
                latency=ipSettings.Latency;
            end
        end
    end

    methods(Access=private)
        function[newComp,status,IPName]=generateIP(this,ntk,c,compType,latencyFreq,isFreqDriven)
            switch compType
            case{'target_add_comp','add_comp'}
                inputSigns=c.getInputSigns;
                if strcmp(inputSigns,'++')

                    [newComp,status]=alteratarget.getMegaFunctionCompFPF(@alteratarget.getAddMegaFunctionCompFPF,{this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,latencyFreq,isFreqDriven});
                elseif strcmp(inputSigns,'+-')

                    [newComp,status]=alteratarget.getMegaFunctionCompFPF(@alteratarget.getSubMegaFunctionCompFPF,{this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,latencyFreq,isFreqDriven});
                else
                    assert(0);
                end
                IPName='addsub';
            case{'target_mul_comp','mul_comp'}
                inputSigns=c.getInputSigns;
                if strcmp(inputSigns,'**')

                    [newComp,status]=alteratarget.getMegaFunctionCompFPF(@alteratarget.getMulMegaFunctionCompFPF,{this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,latencyFreq,isFreqDriven});
                    IPName='mul';
                elseif strcmp(inputSigns,'*/')

                    [newComp,status]=alteratarget.getMegaFunctionCompFPF(@alteratarget.getDivMegaFunctionCompFPF,{this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,latencyFreq,isFreqDriven});
                    IPName='div';
                else
                    assert(0);
                end
            case{'target_conv_comp','data_conv_comp'}

                assert(~isEqual(c.PirInputSignals.Type,c.PirOutputSignals.Type));
                [newComp,status]=alteratarget.getMegaFunctionCompFPF(@alteratarget.getDTCMegaFunctionCompFPF,{this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,latencyFreq,isFreqDriven});
                IPName='conv';
            case{'target_relop_comp','relop_comp'}

                [newComp,status]=alteratarget.getMegaFunctionCompFPF(@alteratarget.getRelopMegaFunctionCompFPF,{this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,latencyFreq,isFreqDriven,c.getOpName});
                IPName='relop';
            case{'target_abs_comp','abs_comp'}

                [newComp,status]=alteratarget.getMegaFunctionCompFPF(@alteratarget.getAbsMegaFunctionCompFPF,{this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,latencyFreq,isFreqDriven});
                IPName='abs';
            case{'target_sqrt_comp','sqrt_comp'}
                fcnName=c.getFunctionName;
                if strcmpi(fcnName,'sqrt')

                    [newComp,status]=alteratarget.getMegaFunctionCompFPF(@alteratarget.getSqrtMegaFunctionCompFPF,{this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,latencyFreq,isFreqDriven});
                    IPName='sqrt';
                elseif strcmpi(fcnName,'rsqrt')

                    [newComp,status]=alteratarget.getMegaFunctionCompFPF(@alteratarget.getInvSqrtMegaFunctionCompFPF,{this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,latencyFreq,isFreqDriven});
                    IPName='rsqrt';
                else
                    assert(0);
                end
            case{'target_trig_comp','trig_comp'}
                fcnName=c.getFunctionName;
                if strcmpi(fcnName,'sin')

                    [newComp,status]=alteratarget.getMegaFunctionCompFPF(@alteratarget.getSinMegaFunctionCompFPF,{this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,latencyFreq,isFreqDriven});
                    IPName='sin';
                elseif strcmpi(fcnName,'cos')

                    [newComp,status]=alteratarget.getMegaFunctionCompFPF(@alteratarget.getCosMegaFunctionCompFPF,{this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,latencyFreq,isFreqDriven});
                    IPName='cos';
                else
                    assert(0);
                end
            case{'target_math_comp','math_comp'}
                fcnName=c.getFunctionName;
                if strcmpi(fcnName,'reciprocal')

                    [newComp,status]=alteratarget.getMegaFunctionCompFPF(@alteratarget.getInvMegaFunctionCompFPF,{this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,latencyFreq,isFreqDriven});
                    IPName='recip';
                elseif strcmpi(fcnName,'exp')

                    [newComp,status]=alteratarget.getMegaFunctionCompFPF(@alteratarget.getExpMegaFunctionCompFPF,{this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,latencyFreq,isFreqDriven});
                    IPName='exp';
                elseif strcmpi(fcnName,'log')

                    [newComp,status]=alteratarget.getMegaFunctionCompFPF(@alteratarget.getLogMegaFunctionCompFPF,{this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,latencyFreq,isFreqDriven});
                    IPName='log';
                else
                    assert(0);
                end
            case{'target_scalarmac_comp','scalarmac_comp'}

                [newComp,status]=alteratarget.getMegaFunctionCompFPF(@alteratarget.getMultAddMegaFunctionCompFPF,{this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,latencyFreq,isFreqDriven});
                IPName='multadd';
            otherwise



                newComp=[];
                status=[];
            end
        end

        function replaceWithALTERAFPF(this,ntk,c)
            customizedLatency=this.getCustomizedLatency(c);
            if(customizedLatency~=-1)
                latencyFreq=customizedLatency;
                isFreqDriven=false;
            else
                latencyFreq=this.getDesiredFrequence();
                isFreqDriven=true;
            end

            compType=c.ClassName;
            if(strcmpi(compType,'target_conv_comp')&&isEqual(c.PirInputSignals.Type,c.PirOutputSignals.Type))

                newComp=pirelab.getWireComp(ntk,c.PirInputSignals,c.PirOutputSignals);
            else
                [newComp,status]=this.generateIP(ntk,c,compType,latencyFreq,isFreqDriven);
                if(~isempty(status))

                    assert(status.status==0);
                    hCurrentDriver=hdlcurrentdriver();
                    codeGenDir=hCurrentDriver.hdlGetBaseCodegendir();
                    ipDir=status.path;
                    hex=dir(fullfile(ipDir,'*.hex'));
                    for i=1:length(hex)
                        s=copyfile(fullfile(ipDir,hex(i).name),codeGenDir);
                        assert(s==1);
                        targetcodegen.alteradspbadriver.addDSPBAAdditionalFiles(hex(i).name);
                    end
                    mif=dir(fullfile(ipDir,'*.mif'));
                    for i=1:length(mif)
                        s=copyfile(fullfile(ipDir,mif(i).name),codeGenDir);
                        assert(s==1);
                        targetcodegen.alteradspbadriver.addDSPBAAdditionalFiles(mif(i).name);
                    end
                end
            end

            if~isempty(newComp)

                newComp.copyComment(c);
                targetcodegen.basedriver.disconnectReceivers(c.PirInputSignals,c);
                targetcodegen.basedriver.disconnectDrivers(c.PirOutputSignals,c);
            end
        end

        function freq=getDesiredFrequence(~)
            hCurrentDriver=hdlcurrentdriver();
            freq=int32(hCurrentDriver.getOptimizationFrequencyGoal());
        end
    end

    methods(Static=true)

        function name=getMaskName(compClass)
            name=targetcodegen.basedriver.getMaskNamePrivate(compClass,'ALTERAFPF\n');
        end


        function name=getFunctionName(varargin)
            name=targetcodegen.basedriver.getFunctionNamePrivate('alterafpf_',varargin{:});
        end


        function toolPath=getToolPath()
            synthTool=hdlgetparameter('SynthesisTool');
            try
                if strcmpi(synthTool,'Intel Quartus Pro')
                    pathToQuartus=hdlgetpathtoquartuspro;
                    toolPath=fullfile(pathToQuartus,'sopc_builder','bin','ip-deploy');
                else
                    pathToQuartus=hdlgetpathtoquartus;
                    toolPath=fullfile(pathToQuartus,'sopc_builder','bin','ip-generate');
                end
            catch me
                lib='ALTERAFPFUNCTIONS';
                toolName=targetcodegen.targetCodeGenerationUtils.getToolName(lib);
                if~ischar(toolName)
                    toolName=char(toolName(1));
                end
                error(message('hdlcommon:targetcodegen:ToolNotSet',lib,toolName));
            end
        end


        function[IPName,idx]=mapToTargetIPName(c)
            idx=c.getTargetIPTypeIndex()+2;
            IPName=targetcodegen.alterafpfdriver.targetCompIPName{idx};
        end
    end
end



