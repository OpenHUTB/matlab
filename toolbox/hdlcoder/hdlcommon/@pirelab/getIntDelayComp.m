function delayComp=getIntDelayComp(hN,hInSignals,hOutSignals,delayNumber,...
    compName,ic,resetType,hasExtEnable,extResetType,...
    ramBased,~,desc,slHandle)







    if(nargin<13)
        slHandle=-1;
    end

    if(nargin<12)
        desc='';
    end

    if(nargin<10)
        ramBased=false;
    end



    if(nargin<9)
        extResetType='';
    end

    if(nargin<8)
        hasExtEnable=false;
    end

    if(nargin<7)
        resetType='';
    end

    if(nargin<6)
        ic=0;
    end

    if(nargin<5)
        compName='intdelay';
    end

    hasExtReset=~isempty(extResetType);

    if hasExtEnable&&hasExtReset
        delayType=hdldelaytypeenum.DelayEnabledResettable;
    elseif hasExtEnable&&~hasExtReset
        delayType=hdldelaytypeenum.DelayEnabled;
    elseif~hasExtEnable&&hasExtReset
        delayType=hdldelaytypeenum.DelayResettable;
    else
        delayType=hdldelaytypeenum.Delay;
    end

    hDinSignal=hInSignals(1);
    if delayNumber==0



        hwSemantics=hN.hasSLHWFriendlySemantics||hN.getWithinHWFriendlyHierarchy;
        if~hwSemantics&&hasExtEnable
            compPath=[hN.FullPath,'/',compName];
            error(message('hdlcoder:validate:Classic0DelayEn',compPath));
        else
            delayComp=pirelab.getWireComp(hN,hDinSignal,hOutSignals,...
            compName,desc,slHandle);
        end
    else
        if delayType==hdldelaytypeenum.Delay
            delayComp=pircore.getIntDelayComp(hN,hDinSignal,hOutSignals,...
            delayNumber,compName,ic,resetType,ramBased,desc,slHandle);
        else
            hExtRstSignal=delayType.getRstSignal(hInSignals);
            hExtEnbSignal=delayType.getEnbSignals(hInSignals);

            delayComp=pircore.getIntDelayEnabledResettableComp(hN,hDinSignal,...
            hOutSignals,delayNumber,compName,ic,resetType,hExtEnbSignal,...
            hExtRstSignal,desc,slHandle);
        end
    end
end
