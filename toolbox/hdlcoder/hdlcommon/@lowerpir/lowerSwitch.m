function hNewC=lowerSwitch(hN,hC)



    if hC.PirInputSignals(2).Type.isArrayType
        inputmode=2;
    else
        inputmode=1;
    end

    selSignal=hC.PirInputSignals(2);
    inSignals=[hC.PirInputSignals(1),hC.PirInputSignals(3)];
    outSignals=hC.PirOutputSignals;
    criteria=hC.getCompareStr;
    compareVal=hC.getThreshold;
    rndMode=hC.getRoundingMode;
    ovMode=hC.getOverflowMode;

    if isempty(rndMode)
        rndMode='floor';
    end

    if isempty(ovMode)
        ovMode='wrap';
    end



    if outSignals.Type.isArrayType
        for ii=1:numel(inSignals)
            if~inSignals(ii).Type.isArrayType
                inSignals(ii)=pirelab.scalarExpand(hN,inSignals(ii),...
                outSignals.Type.Dimensions,outSignals.Type.isRowVector);
            end
        end
    end

    [~,selType]=pirelab.getVectorTypeInfo(selSignal);
    [isNop,condIsTrue]=switchIsNop(selType,criteria,compareVal);

    if isNop
        if condIsTrue
            selectedInput=inSignals(1);
        else
            selectedInput=inSignals(2);
        end

        hNewC=pirelab.getWireComp(hN,selectedInput,outSignals);
        return;
    end

    sel=selSignal;
    inSigs=inSignals;

    compare0=all(compareVal==0);
    compare1=all(compareVal==1);


    if(compare0||compare1)&&(strcmp(criteria,'==')||strcmp(criteria,'~='))

        if(compare0&&strcmp(criteria,'=='))||(compare1&&strcmp(criteria,'~='))
            inSigs=[inSignals(2),inSignals(1)];
        end
    else
        hT=selSignal(1).Type;
        if hT.isArrayType
            selSig=pirelab.demuxSignal(hN,selSignal);
        else
            selSig=selSignal;
        end

        relopOutSig=hdlhandles(numel(selSig),1);
        for ii=1:numel(selSig)
            if numel(compareVal)>1
                cval=pirelab.getTypeInfoAsFi(selSig(1).Type,'Nearest',ovMode,compareVal(ii));
            else
                cval=pirelab.getTypeInfoAsFi(selSig(1).Type,'Nearest',ovMode,compareVal);
            end
            sigName=sprintf('switch_compare_%d',ii);
            relopOutSig(ii)=hN.addSignal(hdlcoder.tp_boolean,sigName);
            compareComp=pireml.getCompareToValueComp(hN,selSig(ii),relopOutSig(ii),...
            criteria,cval,'compareMux');%#ok<NASGU>
        end

        if numel(relopOutSig)>1

            hT=hN.getType('array','BaseType',hdlcoder.tp_boolean,'Dimensions',numel(selSig));
            sel=hN.addSignal(hT,'compareOut');
            muxComp=pirelab.getMuxComp(hN,relopOutSig,sel,'compareMux');%#ok<NASGU>
        else
            sel=relopOutSig;
        end
    end

    hNewC=pireml.getMultiPortSwitchComp(...
    hN,...
    [sel,inSigs(2),inSigs(1)],...
    outSignals,...
    inputmode,...
    'Zero-based contiguous',...
    rndMode,...
    ovMode,...
    hC.Name);

end

function[isNop,switchCond]=switchIsNop(selType,criteria,compareVal)

    isNop=false;
    switchCond=false;

    [lowerBound,upperBound]=pirelab.getTypeBounds(selType);

    if~isempty(lowerBound)&&~isempty(upperBound)
        if all(compareVal<lowerBound)
            isNop=true;
            switch criteria
            case{'<','==','<='}
                switchCond=false;
            otherwise
                switchCond=true;
            end
        elseif all(compareVal>upperBound)
            isNop=true;
            switch criteria
            case{'>','==','>='}
                switchCond=false;
            otherwise
                switchCond=true;
            end
        elseif all(compareVal==lowerBound)
            switch criteria
            case{'<'}
                isNop=true;
                switchCond=false;
            case{'>='}
                isNop=true;
                switchCond=true;
            end
        elseif all(compareVal==upperBound)
            switch criteria
            case{'>'}
                isNop=true;
                switchCond=false;
            case{'<='}
                isNop=true;
                switchCond=true;
            end
        end
    end

end

