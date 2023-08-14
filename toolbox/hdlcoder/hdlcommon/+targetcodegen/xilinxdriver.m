



classdef xilinxdriver<targetcodegen.basedriver
    methods
        function obj=xilinxdriver(varargin)
            obj@targetcodegen.basedriver(varargin{:});
        end


        function flag=isCompCompatible(~,c)
            flag=c.getSupportXilinxCoreGen;
        end


        function replaceWithTargetFunctions(this,p,hdldriver)


            this.createInventoryAndReplaceWithTargetFunctions(p,hdldriver);
        end


        function replaceWithInstantiationComp(this,ntk,c)
            compType=c.ClassName;
            switch compType
            case{'target_add_comp'}
                inputSigns=c.getInputSigns;
                if strcmp(inputSigns,'++')

                    newComp=xilinxtarget.getAddSubCoreGenComp(this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,...
                    'ADD',c.getPipelineDelay);
                elseif strcmp(inputSigns,'+-')

                    newComp=xilinxtarget.getAddSubCoreGenComp(this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,...
                    'SUB',c.getPipelineDelay);
                end
            case{'target_mul_comp'}
                inputSigns=c.getInputSigns;
                if strcmp(inputSigns,'**')

                    newComp=xilinxtarget.getMulCoreGenComp(this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,...
                    c.getPipelineDelay);
                elseif strcmp(inputSigns,'*/')

                    newComp=xilinxtarget.getDivCoreGenComp(this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,...
                    c.getPipelineDelay);
                end
            case{'target_conv_comp'}

                newComp=xilinxtarget.getDTCCoreGenComp(this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,...
                c.getPipelineDelay);
            case{'target_relop_comp'}

                newComp=xilinxtarget.getRelopCoreGenComp(this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,...
                c.getPipelineDelay,c.getOpName);

            case{'target_sqrt_comp'}
                fcnName=c.getFunctionName;
                if strcmpi(fcnName,'sqrt')

                    newComp=xilinxtarget.getSqrtCoreGenComp(this.targetCompInventory,ntk,c.PirInputSignals,c.PirOutputSignals,compType,...
                    c.getPipelineDelay);
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
            end
        end
    end

    methods(Static)

        function name=getMaskName(compClass)
            name=targetcodegen.basedriver.getMaskNamePrivate(compClass,'XIL\n');
        end


        function name=getFunctionName(varargin)
            name=targetcodegen.basedriver.getFunctionNamePrivate('xilfp_',varargin{:});
        end


        function toolPath=getToolPath()
            toolPath=targetcodegen.basedriver.getToolPath('coregen','XILINXLOGICORE');
        end


        function[xilinxPath,xilinxSimLibPath]=getPathToXilinx(lang,tool)


            try

                if tool.isISE
                    path=fileparts(targetcodegen.xilinxdriver.getToolPath);
                    xilinxPath=fileparts(path);
                    xilinxPath=fileparts(xilinxPath);
                    xilinxPath=strrep(xilinxPath,'\','/');

                    xilinxSimLibPath=targetcodegen.xilinxutildriver.getSimulatorLibPath();
                    if~isempty(xilinxSimLibPath)
                        xilinxSimLibPath=strrep(xilinxSimLibPath,'\','/');

                        return;
                    end


                    [status,result]=system(sprintf('compxlib -info %s/%s',xilinxPath,lang));
                    if status==0
                        matched=regexp(result,'\s+Compiled Path\s+=:\s+(?<compiledPath>[\S]+)','names');
                        if~isempty(matched)
                            for i=1:length(matched)
                                if~isempty(strfind(matched(i).compiledPath,'xilinxcorelib'))
                                    xilinxSimLibPath=matched(i).compiledPath;
                                    xilinxSimLibPath=strrep(xilinxSimLibPath,'\','/');
                                    break;
                                end
                            end
                        end
                    end

                elseif tool.isVivado
                    xilinxPath='';
                    xilinxSimLibPath=targetcodegen.xilinxutildriver.getSimulatorLibPath();
                    if~isempty(xilinxSimLibPath)
                        xilinxSimLibPath=strrep(xilinxSimLibPath,'\','/');

                        return;
                    else
                        status=1;
                    end
                end


                if(status~=0||isempty(xilinxSimLibPath))
                    xilinxSimLibPath='FILL_XILINX_SIMULATOR_LIB_PATH/xilinxcorelib';
                    hdlDriver=hdlcurrentdriver;
                    if(~isempty(hdlDriver))
                        hdlDriver.addCheckCurrentDriver('Warning',message('hdlcommon:targetcodegen:xilinxsimlibnotcompiled'));
                    else
                        warning(message('hdlcommon:targetcodegen:xilinxsimlibnotcompiled'));
                    end
                end
            catch me
                rethrow(me);
            end

        end
    end
end



