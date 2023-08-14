function usComp=getUpSampleComp(hN,hInSignal,hOutSignal,upSampleFactor,sampleOffset,initVal,compName,desc,slHandle)



    if nargin<9
        slHandle=-1;
    end

    if nargin<8
        desc='';
    end

    if nargin<7
        compName='us';
    end

    if nargin<6
        initVal=0;
    end

    isReset=pircore.processDelayIC(initVal);

    usComp=hN.addComponent2(...
    'kind','upsample',...
    'SimulinkHandle',slHandle,...
    'Name',compName,...
    'InputSignals',hInSignal,...
    'OutputSignals',hOutSignal,...
    'Factor',upSampleFactor,...
    'Offset',sampleOffset,...
    'InitialValue',initVal,...
    'ResetInitVal',isReset,...
    'BlockComment',desc);

end