function addOutportBlocks(this,tgtParentPath,hNtwk)




    numOutports=hNtwk.NumberOfPirOutputPorts;
    vOutports=hNtwk.PirOutputPorts;

    outPortPos=[15,17,50,35];

    conditional=hNtwk.hasEnabledInstances||hNtwk.hasTriggeredInstances;

    for i=1:numOutports
        hP=vOutports(i);
        slBlockName=[tgtParentPath,'/',hP.Name];
        isInTriggeredNet=hNtwk.isInTriggeredHierarchy;
        hN=hP.Owner;

        if~hP.isTestpoint&&hP.Signal.Type.isRecordType&&hNtwk.SimulinkHandle~=-1

            if strcmp(get_param(hN.SimulinkHandle,'Type'),'block_diagram')||...
                strcmp(get_param(hN.SimulinkHandle,'BlockType'),'SubSystem')

                if addOutBusElementPortBlocks(this,hP,slBlockName,tgtParentPath,hNtwk.SimulinkHandle)
                    continue;
                end
            end
        end

        [~,portHandle]=addBlock(this,[],'built-in/Outport',slBlockName);
        set_param(slBlockName,'Position',outPortPos);
        name=get_param(portHandle,'Name');
        name=strrep(name,'/','//');
        if~strcmpi(hP.Name,name)
            hP.Name=name;
            slBlockName=[tgtParentPath,'/',hP.Name];
        end

        hP.setGMHandle(portHandle);



        initVal='0';

        if~hN.Synthetic





            if hN.isBusExpansionSubsystem
                outportPath=find_system(hN.FullPath,...
                'LookUnderMasks','all','SearchDepth',1,...
                'blocktype','Outport','port',sprintf('%d',hP.getOrigPIRPortNum+1));

                slHandle=[];
                if~isempty(outportPath)
                    slHandle=get_param(outportPath{1},'Handle');
                end
            else
                slHandle=find_system(hN.SimulinkHandle,'MatchFilter',@Simulink.match.allVariants,...
                'LookUnderMasks','all','SearchDepth',1,...
                'blocktype','Outport','port',sprintf('%d',hP.getOrigPIRPortNum+1));
            end

            if~isempty(slHandle)
                if hP.didPIRPortNumChange&&hP.isData
                    handleMaskParams(this,slBlockName,slHandle,hP.Owner,true,hP.PortIndex+1);
                else
                    handleMaskParams(this,slBlockName,slHandle,hP.Owner,true);
                end
            end
        else
            hS=hP.Signal;


            if isa(hS,'hdlcoder.signal')&&~hS.Type.BaseType.isRecordType
                sltype=computeDataType(this,hS.Type);
                setDataType(this,slBlockName,sltype);
            end


            bt=hS.Type.BaseType;



            if bt.isEnumType
                initVal='[]';
            end
        end




        setPortSampleTime(this,hN.PirOutputSignals(i),hP.Component,...
        portHandle,isInTriggeredNet);

        if conditional
            set_param(slBlockName,'InitialOutput',initVal);
        end

        if hP.isData
            this.modelgenset_param(slBlockName,'IOInterface',hP.getIOInterface);
            this.modelgenset_param(slBlockName,'IOInterfaceMapping',hP.getIOInterfaceMapping);
        end
    end
end


