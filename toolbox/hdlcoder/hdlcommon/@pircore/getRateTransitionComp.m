function rtComp=getRateTransitionComp(hN,hInSignals,hOutSignals,outputRate,initVal,compName,desc,slHandle,integrity,deterministic)


    if nargin<10
        integrity=true;
    end

    if nargin<9
        deterministic=true;
    end

    if nargin<8
        slHandle=-1;
    end

    if nargin<7
        desc='';
    end

    if nargin<6
        compName='rt';
    end

    if nargin<5||isempty(initVal)
        initVal=pirelab.getTypeInfoAsFi(hInSignals.Type);
    end

    isReset=pircore.processDelayIC(initVal);

    inputRate=hInSignals.SimulinkRate;
    if(inputRate>=outputRate)
        rateup=true;
        factor=int32(inputRate/outputRate);
    else
        rateup=false;
        factor=int32(outputRate/inputRate);
    end

    rtComp=hN.addComponent2(...
    'kind','ratetransition',...
    'SimulinkHandle',slHandle,...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'Factor',factor,...
    'RateUp',rateup,...
    'InitialValue',initVal,...
    'ResetInitVal',isReset,...
    'Integrity',integrity,...
    'Deterministic',deterministic,...
    'BlockComment',desc);



    hOutSignals.SimulinkRate=outputRate;

end
