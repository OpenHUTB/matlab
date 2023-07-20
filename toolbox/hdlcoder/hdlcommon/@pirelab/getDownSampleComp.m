function dsComp=getDownSampleComp(hN,hInSignal,hOutSignal,downSampleFactor,sampleOffset,ic,compName,desc,slHandle)
















    if nargin<9
        slHandle=-1;
    end

    if nargin<8
        desc='';
    end

    if nargin<7
        compName='downsample';
    end

    if nargin<6||isempty(ic)
        ic=pirelab.getTypeInfoAsFi(hInSignal.Type);
    end

    dsComp=pircore.getDownSampleComp(hN,hInSignal,hOutSignal,downSampleFactor,sampleOffset,ic,compName,desc,slHandle);
