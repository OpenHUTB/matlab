function addInportBlocks(this,tgtParentPath,hNtwkOrComp,isDUT)




    if nargin<4
        isDUT=0;
    end
    numInports=hNtwkOrComp.NumberOfPirInputPorts;
    vInports=hNtwkOrComp.PirInputPorts;

    inPortPos=[15,17,50,35];
    contrPortPos=[15,20,35,40];

    for i=1:numInports
        hP=vInports(i);
        hN=hP.Owner;
        isTriggeredNet=hN.isInTriggeredHierarchy;

        slBlockName=[tgtParentPath,'/',hP.Name];




        sampleTimeStr='';












        if(hN.isSequentialPartition||hN.needsScheduling)
            set_param(tgtParentPath,'MinAlgLoopOccurrences','on');
            set_param(bdroot(tgtParentPath),'ArtificialAlgebraicLoopMsg','none');
        end
        if hP.isSubsystemEnable
            slHandle=[];

            [slBlockName,gmHandle]=addBlock(this,[],'built-in/EnablePort',slBlockName);
            set_param(slBlockName,'Position',contrPortPos);

            if~hN.Synthetic

                slHandle=find_system(hN.SimulinkHandle,'MatchFilter',@Simulink.match.allVariants,...
                'LookUnderMasks','all','SearchDepth',1,...
                'blocktype','EnablePort');
            end
        elseif(hP.isSubsystemSyncReset)

            slBlockName=slpir.PIR2SL.getUniqueName(slBlockName);
            gmHandle=add_block('built-in/ResetPort',slBlockName);
            set_param(slBlockName,'Position',contrPortPos);

            if hN.Synthetic
                slHandle=[];
            else

                slHandle=find_system(hN.SimulinkHandle,'MatchFilter',@Simulink.match.allVariants,...
                'LookUnderMasks','all','SearchDepth',1,...
                'blocktype','ResetPort');
            end
        elseif(hP.isSubsystemTrigger)
            if this.isSFNetwork(hNtwkOrComp.SimulinkHandle)
                [slBlockName,gmHandle]=addBlock(this,[],'built-in/Inport',slBlockName);
                set_param(slBlockName,'Position',inPortPos);
                slHandle=[];
            else
                [slBlockName,gmHandle]=addBlock(this,[],'built-in/TriggerPort',slBlockName);
                set_param(slBlockName,'Position',contrPortPos);
                slHandle=find_system(hN.SimulinkHandle,'MatchFilter',@Simulink.match.allVariants,...
                'LookUnderMasks','all','SearchDepth',1,...
                'blocktype','TriggerPort');
            end
        else
            if~hP.isTestpoint&&hP.Signal.Type.isRecordType&&hN.SimulinkHandle~=-1

                if strcmp(get_param(hN.SimulinkHandle,'Type'),'block_diagram')||...
                    strcmp(get_param(hN.SimulinkHandle,'BlockType'),'SubSystem')


                    if addInBusElementPortBlocks(this,hP,slBlockName,tgtParentPath,hN.SimulinkHandle)
                        continue;
                    end
                end
            end



            [slBlockName,portHandle]=addBlock(this,[],'built-in/Inport',slBlockName);
            set_param(slBlockName,'Position',inPortPos);
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
                if~isKey(this.tunablePorts,hP.getTunableName())
                    this.tunablePorts(hP.getTunableName())=portInfo;
                end






                if(hP.Signal.Type.isComplexType())
                    set_param(gmHandle,'SignalType','complex');
                else
                    set_param(gmHandle,'SignalType','real');
                end

                if(hP.Signal.Type.isArrayType)
                    dims=getDimensionsStr(this,hpT);
                    if~isempty(dims)
                        set_param(portHandle,'PortDimensions',dims);
                    end
                else
                    set_param(portHandle,'PortDimensions','[1]')
                end
            end


            sampleTimeStr=setPortSampleTime(this,hN.PirInputSignals(i),hP.Component,...
            portHandle,isTriggeredNet);

            if~hN.Synthetic





                if hN.isBusExpansionSubsystem
                    inportPath=(find_system(hN.FullPath,...
                    'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','all','SearchDepth',1,...
                    'blocktype','Inport','port',sprintf('%d',hP.getOrigPIRPortNum+1)));

                    slHandle=[];
                    if~isempty(inportPath)
                        slHandle=get_param(inportPath{1},'Handle');
                    end
                else
                    slHandle=find_system(get_param(hN.SimulinkHandle,'Handle'),...
                    'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','all','SearchDepth',1,...
                    'blocktype','Inport','port',sprintf('%d',hP.getOrigPIRPortNum+1));
                end
            else
                slHandle=[];
            end
        end

        hP.setGMHandle(gmHandle);

        if~isempty(slHandle)
            if hP.didPIRPortNumChange&&hP.isData
                handleMaskParams(this,slBlockName,slHandle,hP.Owner,true,hP.PortIndex+1);
            else
                handleMaskParams(this,slBlockName,slHandle,hP.Owner,true);
            end




            if(~isempty(sampleTimeStr))
                set_param(slBlockName,'SampleTime',sampleTimeStr);
            end


            if isa(hP.Signal,'hdlcoder.signal')
                hpT=hP.Signal.Type;

                dims=getDimensionsStr(this,hpT);
                objParams=get_param(slBlockName,'ObjectParameters');
                if~isempty(dims)&&...
                    isfield(objParams,'PortDimensions')
                    set_param(slBlockName,'PortDimensions',dims);
                end


                if true
                    hS=hP.Signal;
                    sltype=computeDataType(this,hS.Type);
                    if~hS.Type.isRecordType&&~hP.isSubsystemSyncReset&&...
                        ~hS.Type.isArrayOfRecords&&~hS.Type.isParameterizedType
                        setDataType(this,slBlockName,sltype)
                    end
                end
            end
        else









            hS=hP.Signal;
            if isa(hS,'hdlcoder.signal')
                sltype=computeDataType(this,hS.Type);
                if~hS.Type.isRecordType&&~hP.isSubsystemSyncReset&&...
                    ~hS.Type.isArrayOfRecords&&~hS.Type.isParameterizedType
                    setDataType(this,slBlockName,sltype);
                    if targetcodegen.targetCodeGenerationUtils.isFloatingPointMode()

                        setDataTypeOverrideOff(slBlockName,hS.Type);
                    end
                end
            end
            if hP.isSubsystemSyncReset
                if hP.Owner.hasSLHWFriendlySemantics||hP.Owner.getWithinHWFriendlyHierarchy
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




function setDataTypeOverrideOff(slBlockName,hsType)

    if hsType.isArrayType||hsType.isComplexType()

        hsType=hsType.getLeafType;
    end

    if hsType.isFloatType
        return;
    end

    if~hsType.isWordType
        return;
    end

    if isprop(hsType,'WordLength')
        isSigned=hsType.Signed;
        wordLen=hsType.WordLength;
        fracLen=hsType.FractionLength;
        DTStr=['fixdt(',num2str(isSigned),',',num2str(wordLen),',',num2str(-fracLen),',','''DataTypeOverride'', ''Off'')'];
        set_param(slBlockName,'OutDataTypeStr',DTStr);
    end
end


