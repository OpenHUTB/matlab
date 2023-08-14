



classdef alteradriver<targetcodegen.basedriver
    properties(SetAccess=protected,GetAccess=protected)
    end

    methods
        function obj=alteradriver(varargin)
            obj@targetcodegen.basedriver(varargin{:});
        end


        function flag=isCompCompatible(~,c)
            flag=c.getSupportAlteraMegaFunctions;
        end


        function replaceWithTargetFunctions(this,p,hdldriver)
            objectiveValue=int8(targetcodegen.targetCodeGenerationUtils.getConfigurationObject.LibrarySettings.Objective);
            assert(~strcmpi('NONE',objectiveValue));


            this.createInventoryAndReplaceWithTargetFunctions(p,hdldriver);
        end


        function replaceWithInstantiationComp(this,ntk,c)
            replaceWithALTFP(this,ntk,c);
        end


        function[latency,isLatencyCustom]=getDefaultLatency(this,targetIPType,targetCompDataType,~)
            if strcmpi(targetIPType,'UMINUS')
                latency=0;
                return;
            end
            assert(strcmpi(class(this.config.m_strategy),'fpconfig.LatencyDrivenStrategy'));
            ipSettings=this.config.IPConfig.getIPSettings(targetIPType,targetCompDataType);
            isLatencyCustom=false;
            if(isempty(ipSettings))
                latency=-1;
            elseif(ipSettings.Latency==-1)
                if(strcmpi(this.config.LibrarySettings.LatencyStrategy,'MIN'))
                    latency=ipSettings.MinLatency;
                else
                    latency=ipSettings.MaxLatency;
                end
            else
                latency=ipSettings.Latency;
                hdlDriver=hdlcurrentdriver;
                if(~isempty(hdlDriver))
                    hdlDriver.addCheckCurrentDriver('Warning',message('hdlcommon:targetcodegen:AltfpCustomizedLatency',latency,targetIPType));
                else
                    warning(message('hdlcommon:targetcodegen:AltfpCustomizedLatency',latency,targetIPType));
                end
            end
        end
    end

    methods(Access=private)
        function replaceWithALTFP(this,ntk,c)
            compType=c.ClassName;
            switch compType
            case{'target_add_comp'}
                inputSigns=c.getInputSigns;
                if strcmp(inputSigns,'++')

                    newComp=alteratarget.getAddSubMegaFunctionComp(this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,...
                    'ADD',c.getPipelineDelay);
                elseif strcmp(inputSigns,'+-')

                    newComp=alteratarget.getAddSubMegaFunctionComp(this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,...
                    'SUB',c.getPipelineDelay);
                end
            case{'target_mul_comp'}
                inputSigns=c.getInputSigns;
                if strcmp(inputSigns,'**')

                    newComp=alteratarget.getMulMegaFunctionComp(this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,...
                    c.getPipelineDelay);
                elseif strcmp(inputSigns,'*/')

                    newComp=alteratarget.getDivMegaFunctionComp(this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,...
                    c.getPipelineDelay);
                end
            case{'target_conv_comp'}

                if isEqual(c.PirInputSignals.Type,c.PirOutputSignals.Type)

                    newComp=pirelab.getWireComp(ntk,c.PirInputSignals,c.PirOutputSignals);
                else
                    newComp=alteratarget.getDTCMegaFunctionComp(this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,...
                    c.getPipelineDelay);
                end
            case{'target_relop_comp'}

                newComp=alteratarget.getRelopMegaFunctionComp(this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,...
                c.getPipelineDelay,c.getOpName);
            case{'target_abs_comp'}

                newComp=alteratarget.getAbsMegaFunctionComp(this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,...
                c.getPipelineDelay);
            case{'target_sqrt_comp'}
                fcnName=c.getFunctionName;
                if strcmpi(fcnName,'sqrt')

                    newComp=alteratarget.getSqrtMegaFunctionComp(this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,...
                    c.getPipelineDelay);
                elseif strcmpi(fcnName,'rsqrt')

                    newComp=alteratarget.getInvSqrtMegaFunctionComp(this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,...
                    'ISQRT',c.getPipelineDelay);
                end
            case{'target_trig_comp'}
                fcnName=c.getFunctionName;
                if strcmpi(fcnName,'sin')

                    newComp=alteratarget.getSinCosMegaFunctionComp(this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,...
                    'SIN',c.getPipelineDelay);
                elseif strcmpi(fcnName,'cos')

                    newComp=alteratarget.getSinCosMegaFunctionComp(this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,...
                    'COS',c.getPipelineDelay);
                end

            case{'target_math_comp'}
                fcnName=c.getFunctionName;
                if strcmpi(fcnName,'reciprocal')

                    newComp=alteratarget.getInvMegaFunctionComp(this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,...
                    'INV',c.getPipelineDelay);
                elseif strcmpi(fcnName,'exp')

                    newComp=alteratarget.getExpMegaFunctionComp(this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,...
                    'EXP',c.getPipelineDelay);
                elseif strcmpi(fcnName,'log')

                    newComp=alteratarget.getLogMegaFunctionComp(this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,...
                    'LOG',c.getPipelineDelay);
                end
            otherwise



                newComp=[];
            end
            if~isempty(newComp)

                newComp.copyComment(c);
                targetcodegen.basedriver.disconnectReceivers(c.PirInputSignals,c);
                targetcodegen.basedriver.disconnectDrivers(c.PirOutputSignals,c);
            end
        end
    end

    methods(Static)

        function name=getMaskName(compClass)
            name=targetcodegen.basedriver.getMaskNamePrivate(compClass,'ALT\n');
        end


        function name=getFunctionName(varargin)
            name=targetcodegen.basedriver.getFunctionNamePrivate('altfp_',varargin{:});
        end


        function toolPath=getToolPath()
            toolPath=targetcodegen.basedriver.getToolPath('qmegawiz','ALTFP');
        end

    end
end


