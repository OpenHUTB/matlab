function hS=pirGetSignal(this,hThisNetwork,slbh,oportHandle)




    [sigName,preserve]=slhdlcoder.SimulinkFrontEnd.pirGetSignalName(slbh,oportHandle);

    sigDesc=get_param(oportHandle,'Description');

    hasFrames=get_param(oportHandle,'CompiledPortFrameData');
    if hasFrames
        msgobj=message('hdlcoder:engine:framebasedmodel');
        this.updateChecks(getfullname(slbh),'block',msgobj,'Error');
    end

    isVariableSizeSignal=get_param(oportHandle,'CompiledPortDimensionsMode');
    if isVariableSizeSignal
        msgobj=message('hdlcoder:engine:variablesizesignal',sigName);
        this.updateChecks(getfullname(slbh),'block',msgobj,'Error');
    end


    bsWarn=warning('off','Simulink:blocks:StrictMsgIsSetToNonStrictSigHier');
    slw=sllastwarning;
    [lw,lwid]=lastwarn;
    sigHier=get_param(oportHandle,'SignalHierarchy');

    [~]=warning(bsWarn.state,'Simulink:blocks:StrictMsgIsSetToNonStrictSigHier');
    sllastwarning(slw);
    lastwarn(lw,lwid);

    if isempty(sigHier)
        sigIsBus=0;
    else
        if isempty(sigHier.Children)
            sigIsBus=0;
        else
            sigIsBus=1;
        end
        if strcmp(get_param(slbh,'BlockType'),'BusSelector')
            sigName=sigHier.SignalName;
        end
    end

    if strcmp(get_param(oportHandle,'PortType'),'connection')
        amsNode=true;
    else
        amsNode=false;
    end


    if amsNode
        pirSignalType=pir_double_t;
    elseif~sigIsBus

        pirSignalType=getSignalType(this,slbh,oportHandle);
    else

        pirSignalType=getSignalTypeForBus(this,hThisNetwork,slbh,oportHandle,sigHier);
    end


    hS=hThisNetwork.addSignal;
    hS.Name=this.validateAndGetName(sigName);
    hS.Type=pirSignalType;
    hS.SimulinkHandle=oportHandle;
    hS.addComment(sigDesc);

    if~amsNode&&~(this.SimulinkConnection.Model.isSampleTimeInherited&&...
        this.TreatAsReferencedModel)
        hS.SimulinkRate=getSigRate(this,oportHandle);
    end






    if~hThisNetwork.isBusExpansionSubsystem
        hS.Preserve(preserve);
    end


    if any(sigDesc>=256)
        blkpath=getfullname(slbh);
        msgobj=message('hdlcoder:validate:LineTextI18N',blkpath,this.SimulinkConnection.Model.Name);
        type='block';
        level=this.HDLCoder.getNonAsciiMessageLevel;

        this.updateChecks(blkpath,type,msgobj,level)
    end
end




function pirSignalType=getDummyType(slSignalType)
    try
        pirSignalType=getpirsignaltype(slSignalType);
    catch me %#ok<NASGU>
        pirSignalType=hdlcoder.tp_unsigned(32);
    end
end


function pirSignalType=getSignalTypeForBus(this,hThisNetwork,slbh,oportHandle,sigHier)
    if slhdlcoder.SimulinkFrontEnd.isBusExpansionSubsystem(slbh)


        hC=hThisNetwork.findComponent('sl_handle',slbh);
        if~isempty(hC)
            portIndex=get_param(oportHandle,'PortNumber');
            pirSignalType=hC.ReferenceNetwork.PirOutputSignals(portIndex).Type;
        else
            pirSignalType=this.createPIRrecordType(slbh,oportHandle,sigHier);
        end
    else
        pirSignalType=this.createPIRrecordType(slbh,oportHandle,sigHier);
    end
end


function pirSignalType=getSignalType(this,slbh,oportHandle)
    slSignalType=get_param(oportHandle,'CompiledPortDataType');
    isComplex=get_param(oportHandle,'CompiledPortComplexSignal');
    portDims=get_param(oportHandle,'CompiledPortDimensions');

    [valid,msgobj,level]=slhdlcoder.SimulinkFrontEnd.isaValidType(slSignalType,...
    portDims);
    if~isempty(msgobj)
        this.updateChecks(getfullname(slbh),'block',msgobj,level);
    end

    if valid
        parsedoutdims=hdlparseportdims(portDims,1);
        dims=[parsedoutdims(2:end,1)];
        if strncmp(slSignalType,'str',3)
            if(length(slSignalType)>3)
                dims=[1,str2double(slSignalType(4:end))];
            end
        end
        pirSignalType=getpirsignaltype(slSignalType,isComplex,dims);
    else
        pirSignalType=getDummyType(slSignalType);
    end
end

