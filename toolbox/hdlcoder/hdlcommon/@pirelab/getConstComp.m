function constComp=getConstComp(hN,hOutSignal,constValue,compName,...
    vectorParams1D,isConstZero,TunableParamStr,ConstBusName,ConstBusType,...
    ~)













    if nargin<9
        ConstBusType='';
    end

    if nargin<8
        ConstBusName='';
    end

    if nargin<7
        TunableParamStr='';
    end

    if nargin<6
        isConstZero=false;
    end

    if nargin<5
        vectorParams1D='on';
    end

    if nargin<4
        compName='const';
    end

    cVal=constValue;
    hT=hOutSignal(1).Type;
    if~hT.isRecordType&&~hT.isArrayOfRecords
        if all(constValue(:)==constValue(1))

            constValue=constValue(1);
        end
        if~(isCharType(hT.getLeafType)||isscalar(constValue))
            cVal=pirelab.getValueWithType(constValue,hT);
        else
            cVal=pirelab.getValueWithType(constValue,hT,false);
        end
    end

    constComp=pircore.getConstComp(hN,hOutSignal,cVal,compName,...
    vectorParams1D,isConstZero,TunableParamStr,ConstBusName,...
    ConstBusType);
end
