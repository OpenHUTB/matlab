function maddComp=getScalarMACComp(hN,hInSignals,hOutSignals,rndMode,ovMode,compName,desc,slbh,hwModeLatency,adderSign,nfpOptions,fused)



    if nargin<12
        fused=false;
    end

    if nargin<11
        nfpOptions.Latency=int8(0);
        nfpOptions.MantMul=int8(0);
        nfpOptions.Denormals=int8(0);
    end

    if nargin<10
        adderSign='++';
    end

    if nargin<9
        hwModeLatency=false;
    end

    if nargin<8
        slbh=-1;
    end

    if nargin<7
        desc='';
    end


    maddComp=hN.addComponent2(...
    'kind','scalarmac',...
    'SimulinkHandle',slbh,...
    'name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'RoundingMode',rndMode,...
    'OverflowMode',ovMode,...
    'BlockComment',desc,...
    'HwModeDelays',hwModeLatency,...
    'AdderSign',adderSign,...
    'NFPLatency',nfpOptions.Latency,...
    'NFPMantMul',nfpOptions.MantMul,...
    'NFPDenormals',nfpOptions.Denormals,...
    'NFPFMA',fused);





end
