function dsComp=getDownSampleComp(hN,hInSignal,hOutSignal,downSampleFactor,sampleOffset,initVal,compName,desc,slHandle)




    if nargin<9
        slHandle=-1;
    end

    if nargin<8
        desc='';
    end

    if nargin<7
        compName='ds';
    end

    if nargin<6
        initVal=pirelab.getTypeInfoAsFi(hInSignal.Type);
    end

    isReset=pircore.processDelayIC(initVal);

    dsComp=hN.addComponent2(...
    'kind','downsample',...
    'SimulinkHandle',slHandle,...
    'Name',compName,...
    'InputSignals',hInSignal,...
    'OutputSignals',hOutSignal,...
    'Factor',downSampleFactor,...
    'Offset',sampleOffset,...
    'InitialValue',initVal,...
    'ResetInitVal',isReset,...
    'BlockComment',desc);

end
