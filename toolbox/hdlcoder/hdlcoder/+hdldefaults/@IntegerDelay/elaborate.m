function idComp=elaborate(this,hN,hC)




    [initVal,numDelays,hasExtEnable,resetnone,rtype,extrtype,rambased,isVarDelay,delayLimit]=...
    getBlockInfo(this,hC);

    if~isempty(rtype)
        resetnone=strcmpi(rtype,'none');
    end

    hwSemantics=hN.getWithinHWFriendlyHierarchy;
    hasExtReset=false;

    if hwSemantics

        if~strcmpi(extrtype,'Level hold')
            extrtype='';
        else
            hasExtReset=true;
        end
    else

        if~strcmpi(extrtype,'Level')
            extrtype='';
        else
            hasExtReset=true;
        end
    end

    if isempty(rambased)
        rambased=0;
    else
        rambased=strcmpi(rambased,'on');
    end

    if~isempty(extrtype)
        rambased=false;
    end

    if~isempty(initVal)
        if all(initVal)
            rambased=false;
        end
    end

    if isa(hC,'hdlcoder.sysobj_comp')

        ipmode='Columns as channels (frame based)';
        hInSignals=hC.PirInputSignals;
        hOutSignals=hC.PirOutputSignals;
    else
        ipmode=get_param(hC.SimulinkHandle,'InputProcessing');
        hInSignals=hC.SLInputSignals;
        hOutSignals=hC.SLOutputSignals;
    end

    if~targetcodegen.targetCodeGenerationUtils.isFloatingPointMode()
        for ii=1:numel(hInSignals)
            if hInSignals(ii).Type.isFloatType()
                rambased=false;
                break;
            end
        end
    end

    if(~isVarDelay)
        if isFrameProcessing(this,hC,ipmode)
            idComp=pirelab.getFrameBasedIntDelayComp(hN,hInSignals,hOutSignals,...
            numDelays,hC.Name,initVal,resetnone,hasExtEnable,extrtype,...
            rambased,false,'',-1);
        else
            idComp=pirelab.getIntDelayComp(hN,hInSignals,hOutSignals,...
            numDelays,hC.Name,initVal,resetnone,hasExtEnable,extrtype,...
            rambased,false,'',-1);
        end

        if hdlgetparameter('preserveDesignDelays')==1


            for nn=1:numel(idComp)
                if(idComp(nn).isDelay)
                    idComp(nn).setDoNotDistribute(1);
                end
            end
        end
        idComp=idComp(end);
    else

        pirTyp=hC.PirInputSignals(1).Type;
        pirTyp_delayLen=hC.PirInputSignals(2).Type;
        hVecT=pirelab.getPirVectorType(pirTyp,delayLimit+1);
        slRate=hC.PirInputSignals(1).SimulinkRate;
        controlSig=hInSignals(2);

        delaySignals=hN.addSignal(hVecT,'delayTapWire');
        controlSatSig=addSignal(hN,'ctrlSat',pirTyp_delayLen,slRate);
        delaySignals.SimulinkRate=slRate;

        if(hasExtReset&&~hasExtEnable)
            tapComp=pirelab.getTapDelayEnabledResettableComp(hN,hInSignals(1),delaySignals,...
            '',hInSignals(3),delayLimit,hC.Name,initVal,false,true,resetnone,hwSemantics);


            tapComp.OrigModelHandle=hC.SimulinkHandle;
        elseif(~hasExtReset&&hasExtEnable)
            tapComp=pirelab.getTapDelayEnabledResettableComp(hN,hInSignals(1),delaySignals,...
            hInSignals(3),'',delayLimit,hC.Name,initVal,false,true,resetnone,hwSemantics);
            tapComp.OrigModelHandle=hC.SimulinkHandle;
        elseif(hasExtReset&&hasExtEnable)
            tapComp=pirelab.getTapDelayEnabledResettableComp(hN,hInSignals(1),delaySignals,...
            hInSignals(3),hInSignals(4),delayLimit,hC.Name,initVal,false,true,resetnone,hwSemantics);
            tapComp.OrigModelHandle=hC.SimulinkHandle;
        else
            pirelab.getTapDelayComp(hN,hInSignals(1),delaySignals,...
            delayLimit,hC.Name,initVal,false,true,resetnone);
        end


        pirelab.getSaturateComp(hN,controlSig,controlSatSig,0,delayLimit);


        if(~hasExtEnable)
            idComp=pirelab.getMultiPortSwitchComp(hN,...
            [controlSatSig,delaySignals],...
            hOutSignals,...
            0,'Zero-based contiguous',...
            'floor',...
            'Wrap',...
            'multiportswitch',...
            [],...
            'Last data port',...
            delayLimit+1);
        else
            delayControlSignalEnb=addSignal(hN,'delayWire',pirTyp_delayLen,slRate);
            controlSignalEnb=hInSignals(3);
            controlSigOut=addSignal(hN,'controlSigOut',pirTyp_delayLen,slRate);
            pirelab.getSwitchComp(hN,...
            [controlSatSig,delayControlSignalEnb],...
            controlSigOut,...
            controlSignalEnb,'Switch',...
            '~=',0);
            pirelab.getUnitDelayComp(hN,controlSigOut,delayControlSignalEnb,'delayControlSig',0);
            idComp=pirelab.getMultiPortSwitchComp(hN,...
            [controlSigOut,delaySignals],...
            hOutSignals,...
            0,'Zero-based contiguous',...
            'floor',...
            'Wrap',...
            'multiportswitch',...
            [],...
            'Last data port',...
            delayLimit+1);
        end
    end

end

function signal=addSignal(network,name,pirType,slRate)
    signal=network.addSignal2('Name',name,'Type',pirType);
    signal.SimulinkRate=slRate;
end

