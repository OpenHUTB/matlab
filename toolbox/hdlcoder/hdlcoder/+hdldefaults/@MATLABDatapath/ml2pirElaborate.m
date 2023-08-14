function hNewC=ml2pirElaborate(this,hN,hC)




    hDriver=hdlcurrentdriver;
    hPir=hDriver.PirInstance;

    createDebugDumps=hdlgetparameter('debug')>=2;
    if createDebugDumps
        cDir=hDriver.hdlGetCodegendir;
        hPir.dumpDot(fullfile(cDir,'pre_ml2pir.dot'));
    end

    mlfbHdl=hC.SimulinkHandle;
    blkname=getfullname(mlfbHdl);


    ramThreshold=hdlgetparameter('RAMMappingThreshold');
    traceability=hdlgetparameter('Traceability');
    implParamNames=this.implParamNames;
    implPvPairs=cell(1,numel(implParamNames)*2);
    idx=1;
    for ii=1:numel(implParamNames)
        param=implParamNames{ii};
        if any(strcmp(param,{'UseMatrixTypesInHDL','VariablesToPipeline',...
            'InputPipeline','OutputPipeline','GuardIndexVariables',...
            'LoopOptimization'}))
            continue;
        end
        val_raw=hdlget_param(blkname,param);
        switch param

        case 'ConstMultiplierOptimization'
            val=0;
            switch lower(val_raw)
            case 'none'
                val=0;
            case 'csd'
                val=1;
            case 'fcsd'
                val=2;
            case 'auto'
                val=3;
            end
        case{'MapPersistentVarsToRAM','InstantiateFunctions'}
            val=strcmpi(val_raw,'on');
        case 'ResetType'
            val=strcmpi(val_raw,'none');
        otherwise

            [~,~,val]=slhdlcoder.SimulinkFrontEnd.validateAndSetNetworkParam(...
            {param,val_raw},blkname);
        end
        assert(~isempty(val),'unexpected implementation parameter found with ML2PIR');
        implPvPairs{idx}=param;
        implPvPairs{idx+1}=val;
        idx=idx+2;
    end

    implPvPairs(idx:end)=[];
    ml2pirSettings=[{'OriginalSLHandle',mlfbHdl,...
    'ParentNetwork',hN,...
    'SLRate',getRate(hC),...
    'RAMMappingThreshold',ramThreshold,...
    'Traceability',traceability,...
    },implPvPairs];

    hNewC=internal.ml2pir.mlfb2pir(blkname,ml2pirSettings{:});

    assert(numel(hC.PirInputPorts)==numel(hNewC.PirInputPorts),...
    'Number of input ports before and after ml2pir do not match.');
    assert(numel(hC.PirOutputPorts)==numel(hNewC.PirOutputPorts),...
    'Number of output ports before and after ml2pir do not match')



    portHdls=get_param(mlfbHdl,'PortHandles');

    inPorts=portHdls.Inport;
    outPorts=portHdls.Outport;






    for i=1:numel(inPorts)
        externalSignal=hC.PirInputPorts(i).Signal;
        busType=get_param(inPorts(i),'CompiledBusType');
        switch busType
        case 'NON_VIRTUAL_BUS'

            convertNonVirtualToVirtualBus(hN,hNewC,externalSignal,i);
        otherwise
            externalSignal.addReceiver(hNewC.PirInputPorts(i));
        end

        alignArrayTypes(externalSignal.Type,hNewC.ReferenceNetwork.PirInputPorts(i));
    end






    for i=1:numel(outPorts)
        externalSignal=hC.PirOutputPorts(i).Signal;
        busType=get_param(outPorts(i),'CompiledBusType');
        switch busType
        case 'NON_VIRTUAL_BUS'




            busObjectName=get_param(outPorts(i),'CompiledPortDataType');
            convertVirtualtoNonVirtualBus(hN,hNewC,externalSignal,i,busObjectName);
        otherwise
            externalSignal.addDriver(hNewC.PirOutputPorts(i));
        end

        alignArrayTypes(externalSignal.Type,hNewC.ReferenceNetwork.PirOutputPorts(i));
    end




    hN.removeComponent(hC)

    if hN.isSFHolder



        internal.ml2pir.PIRGraphBuilder.passOptimizationFlags(hNewC.ReferenceNetwork,hN);

        hN.copyComment(hNewC.ReferenceNetwork);


        internal.ml2pir.PIRGraphBuilder.flattenNetwork(hNewC,false);

        if strcmp(hdlfeature('EnableFlattenSFComp'),'on')&&hN.getFlattenSFHolderNetwork


            hN.setFlattenSFHolderNetwork(false);
        end


        hN.setSFHolder(false);
    end

    if strcmp(hdlfeature('EnableFlattenSFComp'),'off')&&strcmpi(hDriver.getCLI.InlineMATLABBlockCode,'on')





        hNewC.ReferenceNetwork.setFlattenHierarchy('on');
    end

    if createDebugDumps
        hPir.dumpDot(fullfile(cDir,'post_ml2pir.dot'));
        pserl=SerializePir(hPir,'pir_serialized_postml2pir.m');
        pserl.doit;
    end

end

function convertVirtualtoNonVirtualBus(hN,hNewC,externalSignal,idx,busObjectName)




    outSignalNewComp=hN.addSignal(externalSignal.Type,[externalSignal.Name,'_out']);
    outSignalNewComp.SimulinkRate=externalSignal.SimulinkRate;
    outSignalNewComp.addDriver(hNewC.PirOutputPorts(idx));


    hInSignals=extractBusFields(hN,outSignalNewComp);


    hOutSignals=externalSignal;
    pirelab.getBusCreatorComp(hN,hInSignals,hOutSignals,['Bus:',busObjectName],'on');
end

function convertNonVirtualToVirtualBus(hN,hNewC,externalSignal,idx)




    hInSignals=extractBusFields(hN,externalSignal);


    hOutSignals=hN.addSignal(externalSignal.Type,[externalSignal.Name,'_in']);
    hOutSignals.SimulinkRate=externalSignal.SimulinkRate;
    pirelab.getBusCreatorComp(hN,hInSignals,hOutSignals,'','off');
    hOutSignals.addReceiver(hNewC.PirInputPorts(idx))
end

function fieldSignals=extractBusFields(hN,hInSignal)

    memberNames=hInSignal.Type.BaseType.MemberNames;
    nMembers=numel(memberNames);
    fieldSignals=cell(1,nMembers);
    for i=1:nMembers
        fieldSignals{i}=hN.addSignal(hInSignal.Type.BaseType.MemberTypes(i),...
        [hInSignal.Type.BaseType.MemberNames{i},'_in']);
        fieldSignals{i}.SimulinkRate=hInSignal.SimulinkRate;
    end
    outSigNames=strjoin(hInSignal.Type.BaseType.MemberNames,',');
    pirelab.getBusSelectorComp(hN,hInSignal,fieldSignals,outSigNames);
end

function alignArrayTypes(externalSigType,internalPort)





    if~externalSigType.isArrayType||externalSigType.NumberOfDimensions~=1
        return;
    end

    isExtUnordered=~externalSigType.isRowVector&&~externalSigType.isColumnVector;
    if isExtUnordered
        internalSignal=internalPort.Signal;
        hN=internalPort.Owner;
        newSignal=hN.addSignal(externalSigType,[internalSignal.Name,'_reshape']);
        newSignal.SimulinkRate=internalSignal.SimulinkRate;
        if~internalPort.isReceiver

            internalSignal.disconnectDriver(internalPort);
            newSignal.addDriver(internalPort);
            pirelab.getReshapeComp(hN,newSignal,internalSignal);
        else

            internalSignal.disconnectReceiver(internalPort);
            newSignal.addReceiver(internalPort);
            pirelab.getReshapeComp(hN,internalSignal,newSignal);
        end
    end
end

function rate=getRate(hC)

    sigs=hC.getInputSignals('Data');
    if isempty(sigs)
        sigs=hC.getOutputSignals('Data');
    end
    if~isempty(sigs)
        rate=sigs(1).SimulinkRate;
    else


        rate=-1;
    end

end


