function hNewC=elaborateTreeMinMaxValue(this,hN,oldhN,blockInfo,compName)



    opName=blockInfo.compType;
    rndMode=blockInfo.rndMode;
    satMode=blockInfo.satMode;
    nfpOptions=this.getNFPBlockInfo;


    hInputPorts=hN.PirInputPorts;
    hOutputPorts=hN.PirOutputPorts;

    hCInSignal=hN.PirInputSignals(1);
    hCOutSignal=hN.PirOutputSignals(1);


    numInports=length(hInputPorts);
    dimLen=pirelab.getVectorTypeInfo(hCInSignal);


    [opDimLen,~]=pirelab.getVectorTypeInfo(hCOutSignal);


    if numInports==1


        if dimLen==1||(dimLen==opDimLen)

            hNewC=pirelab.getDTCComp(hN,hCInSignal,hCOutSignal,rndMode,satMode);
        else

            hNewC=getTreeArchitecture(this,hN,oldhN,hCInSignal,hInputPorts,hOutputPorts,...
            opName,rndMode,satMode,compName,...
            false,[],int8(0),nfpOptions);
        end
    else
        [hInSignals,inputNeedDTC,aggType]=getTypedInputSignals(blockInfo,hN,hN.PirInputSignals,compName);

        hNewC=getTreeArchitecture(this,hN,oldhN,hInSignals,hInputPorts,hOutputPorts,...
        opName,rndMode,satMode,compName,inputNeedDTC,aggType,...
        int8(0),nfpOptions);
    end
end


function aggType=get_aggregate_type(hInSignals)
    aggType=hInSignals(1).Type.getLeafType;
    for itr=1:length(hInSignals)
        if hInSignals(itr).Type.getLeafType.isFloatType()
            aggType=hInSignals(itr).Type.getLeafType;
        end
    end

    if~aggType.getLeafType.isWordType
        return;
    end


    for itr=1:length(hInSignals)
        q=hInSignals(itr).Type.getLeafType;
        aggType=aggregateType(q,aggType);
    end

    if hInSignals(itr).Type.isArrayType
        af=pir_arr_factory_tc();
        af.addDimension(hInSignals(1).Type.getDimensions);
        af.addBaseType(aggType);
        aggType=pir_array_t(af);
    end
end


function ntype=aggregateType(nt1,nt2)
    if nt1.Signed==nt2.Signed&&nt1.WordLength==nt2.WordLength&&...
        nt1.FractionLength==nt2.FractionLength
        ntype=nt1;
        return;
    end
    if nt1.Signed||nt2.Signed
        if nt1.WordLength-(-nt1.FractionLength)>nt2.WordLength-(-nt2.FractionLength)
            yintbits=nt1.WordLength-(-nt1.FractionLength)+1;
        else
            yintbits=nt2.WordLength-(-nt2.FractionLength)+1;
        end
    else
        if nt1.WordLength-(-nt1.FractionLength)>nt2.WordLength-(-nt2.FractionLength)
            yintbits=nt1.WordLength-(-nt1.FractionLength);
        else
            yintbits=nt2.WordLength-(-nt2.FractionLength);
        end
    end

    yfracbits=max(-nt2.FractionLength,-nt1.FractionLength);
    ntype=pir_fixpt_t(nt1.Signed|nt2.Signed,yintbits+yfracbits,-yfracbits);
end





function[hInSignals,inputNeedDTC,aggType]=getTypedInputSignals(blockInfo,hN,hInputSignals,bname)
    inputNeedDTC=false;
    if strcmpi(blockInfo.InputSameDT,'off')


        first_type={hdlsignalsltype(hInputSignals(1))};
        for itr=2:length(hInputSignals)
            curr_type=hdlsignalsltype(hInputSignals(itr));
            if~strcmpi(first_type,curr_type)
                inputNeedDTC=true;
                break;
            end
        end
    end

    if inputNeedDTC
        hInSignals=[];
        aggType=get_aggregate_type(hInputSignals);
        for itr=1:length(hInputSignals)
            dut_stage_sig=hN.addSignal(aggType,sprintf('%s_op_stage%d',bname,itr));
            pirelab.getDTCComp(hN,hInputSignals(itr),dut_stage_sig,...
            blockInfo.rndMode,blockInfo.satMode);
            hInSignals=[hInSignals;dut_stage_sig];%#ok<*AGROW>
        end
    else
        hInSignals=hInputSignals;
        aggType=hInputSignals(1).Type;
    end
end
