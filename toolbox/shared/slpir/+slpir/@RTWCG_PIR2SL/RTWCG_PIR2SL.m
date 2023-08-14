

classdef RTWCG_PIR2SL<slpir.PIR2SL
    methods
        function this=RTWCG_PIR2SL(hPir,varargin)
            this@slpir.PIR2SL(hPir,varargin{:});
        end

        function drawcomp=shouldDrawComp(this,hC)
            drawcomp=true;

            if~this.isChevronTriggPort(hC)&&~hC.shouldDraw&&~hC.getRtwcgDraw
                drawcomp=false;
            end
        end


        function valid=isValidComp(this,hC,useDotLayout)
            if hC.getRtwcgDraw||this.isChevronTriggPort(hC)
                valid=true;
                return;
            end

            valid=hC.shouldDraw&&useDotLayout&&~hC.isAnnotation;


            if valid&&hC.SimulinkHandle>0
                blkType=get_param(hC.SimulinkHandle,'BlockType');
                if strcmp(blkType,'TriggerPort')||strcmp(blkType,'EnablePort')||strcmp(blkType,'StateEnablePort')||strcmp(blkType,'ActionPort')
                    valid=false;
                end
            end
        end


        function valid=isValidPort(~,hP)
            if hP.getRtwcgDraw
                valid=false;
                return;
            end
            valid=~isempty(hP.Signal);
        end


        function addInportBlocks(this,tgtParentPath,hNtwkOrComp,isDUT)
            if nargin<4
                isDUT=0;
            end
            numInports=hNtwkOrComp.NumberOfPirInputPorts;
            vInports=hNtwkOrComp.PirInputPorts;

            for i=1:numInports
                hP=vInports(i);
                hN=hP.Owner;
                isTriggeredNet=hN.isInTriggeredHierarchy;

                slBlockName=[tgtParentPath,'/',hP.Name];

                sampleTimeStr='';
                if hP.isSubsystemEnable
                    slHandle=[];

                    [slBlockName,gmHandle]=addBlock(this,[],'built-in/EnablePort',slBlockName);


                    if~hN.Synthetic

                        slHandle=find_system(hN.SimulinkHandle,...
                        'LookUnderMasks','all','SearchDepth',1,...
                        'blocktype','EnablePort');
                    end
                elseif(hP.isSubsystemAction)

                    [slBlockName,gmHandle]=addBlock(this,[],'built-in/ActionPort',slBlockName);


                    if~hN.Synthetic

                        slHandle=find_system(hN.SimulinkHandle,...
                        'LookUnderMasks','all','SearchDepth',1,...
                        'blocktype','ActionPort');
                    end
                elseif(hP.isSubsystemSyncReset)

                    gmHandle=add_block('built-in/ResetPort',slBlockName);


                    if~hN.Synthetic

                        slHandle=find_system(hN.SimulinkHandle,...
                        'LookUnderMasks','all','SearchDepth',1,...
                        'blocktype','ResetPort');
                    end
                elseif(hP.isSubsystemTrigger)
                    if this.isSFNetwork(hNtwkOrComp.SimulinkHandle)
                        [slBlockName,gmHandle]=addBlock(this,[],'built-in/Inport',slBlockName);
                        slHandle=[];
                    else
                        [slBlockName,gmHandle]=addBlock(this,[],'built-in/TriggerPort',slBlockName);
                        slHandle=find_system(hN.SimulinkHandle,...
                        'LookUnderMasks','all','SearchDepth',1,...
                        'blocktype','TriggerPort');
                    end
                else



                    [slBlockName,portHandle]=addBlock(this,[],'built-in/Inport',slBlockName);
                    gmHandle=portHandle;
                    name=get_param(portHandle,'Name');
                    name=strrep(name,'/','//');
                    if~strcmpi(hP.Name,name)
                        hP.Name=name;
                    end



                    if~strcmp(hP.getTunableName(),'')
                        portInfo=struct('SLPortHandle',portHandle,...
                        'dataType',getslsignaltype(hP.Signal.Type));
                        if isempty(this.tunablePorts)
                            this.tunablePorts=containers.Map;
                        end
                        this.tunablePorts(hP.getTunableName())=portInfo;
                    end


                    if isa(hN.PirInputSignals(i),'hdlcoder.signal')
                        if~isTriggeredNet
                            hcc=hP.Component;
                            if strcmpi(this.SLEngineDebug,'on')&&hcc.SimulinkHandle>0&&hcc.isNetworkInstance
                                sampleRate=get_param(hcc.SimulinkHandle,'SystemSampleTime');
                                sampleTimeStr=sampleRate;
                            elseif strcmpi(this.SLEngineDebug,'on')&&hcc.SimulinkHandle>0&&~hcc.isCtxReference
                                sampleRate=get_param(hcc.SimulinkHandle,'SampleTime');
                                sampleTimeStr=sampleRate;
                            else
                                sampleRate=hN.PirInputSignals(i).SimulinkRate;
                                if(sampleRate==Inf)
                                    sampleTimeStr='-1';
                                else
                                    sampleTimeStr=sprintf('%16.15g',sampleRate);
                                end
                            end
                            set_param(portHandle,'SampleTime',sampleTimeStr);
                        end
                    else
                        set_param(portHandle,'SampleTime','-1');
                    end

                    if~hN.Synthetic
                        slHandle=find_system(hN.SimulinkHandle,...
                        'MatchFilter',@Simulink.match.allVariants,...
                        'LookUnderMasks','all','SearchDepth',1,...
                        'blocktype','Inport','port',sprintf('%d',hP.PortIndex+1));
                    else
                        slHandle=[];
                    end
                end

                hP.setGMHandle(gmHandle);

                if~isempty(slHandle)
                    handleMaskParams(this,slBlockName,slHandle,hP.Owner,true);


                    if(~isempty(sampleTimeStr))
                        set_param(slBlockName,'SampleTime',sampleTimeStr);
                    end

                    if isa(hP.Signal,'hdlcoder.signal')
                        hpT=hP.Signal.Type;
                        if hpT.isArrayType
                            dims=getDimensionsStr(this,hpT);
                            if~isempty(dims)
                                set_param(portHandle,'PortDimensions',dims);
                            end
                        end
                        if isDUT
                            hS=hP.Signal;
                            sltype=computeDataType(this,hS.Type);
                            if~hS.Type.isRecordType&&~hP.isSubsystemSyncReset&&...
                                ~hS.Type.isParameterizedType
                                setDataType(this,slBlockName,sltype)
                            end
                        end
                    end
                else









                    hS=hP.Signal;
                    if isa(hS,'hdlcoder.signal')
                        sltype=computeDataType(this,hS.Type);
                        if~hS.Type.isRecordType&&~hP.isSubsystemSyncReset&&...
                            ~hS.Type.isParameterizedType
                            setDataType(this,slBlockName,sltype)
                        end
                    end
                    if hP.isSubsystemSyncReset
                        if hP.Owner.hasSLHWFriendlySemantics||...
                            hP.Owner.getWithinHWFriendlyHierarchy
                            set_param(slBlockName,'ResetTriggerType','level hold');
                        else
                            set_param(slBlockName,'ResetTriggerType','level');
                        end
                    end
                end
                if hP.isData
                    this.modelgenset_param(slBlockName,'IOInterface',hP.getIOInterface);
                    this.modelgenset_param(slBlockName,'IOInterfaceMapping',hP.getIOInterfaceMapping);
                end
            end

        end

    end
end


