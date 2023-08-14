function delayComp=getIntDelayComp(hN,hSignalsIn,hSignalsOut,delayNumber,compName,ic,resettype,rambased,desc,slHandle)






    if(nargin<10)
        slHandle=-1;
    end

    if(nargin<9)
        desc='';
    end

    if(nargin<8)
        rambased=false;
    end

    if(nargin<7)
        resettype='';
    end

    if(nargin<6)
        ic='';
    end

    if(nargin<5)
        compName='intdelay';
    end

    if hSignalsIn(1).Type.isEnumType
        ic=pirelab.getTypeInfoAsFi(hSignalsIn(1).Type,'Floor','Wrap',ic);
    end

    if~isempty(ic)&&all(all(ic))~=0
        rambased=false;
    end

    if hSignalsIn(1).Type.getLeafType.isFloatType&&...
        ~targetcodegen.targetCodeGenerationUtils.isFloatingPointMode
        rambased=false;
    end

    if rambased
        rambased=pirelab.getMapDelayToRam(hSignalsIn,delayNumber);
    end


    if rambased
        delayComp=pireml.getIntDelayRamComp(hN,hSignalsIn,hSignalsOut,delayNumber,compName,resettype,desc);
    else


        delayComp=pireml.getIntDelayEnabledResettableComp(hN,hSignalsIn,hSignalsOut,delayNumber,compName,ic,resettype,'','',desc,slHandle);
    end


