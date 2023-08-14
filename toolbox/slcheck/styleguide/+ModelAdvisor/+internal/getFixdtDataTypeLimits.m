function limits=getFixdtDataTypeLimits(arg)
    limits=[];
    if nargin==0
        return;
    end

    if~ischar(arg)
        T=fixdt(arg(1),arg(2),arg(3));
    else
        T=fixdt(arg);
    end

    if isempty(T)
        return;
    end


    if strcmp(T.Signedness,'Signed')
        storedMin=-2^(T.WordLength-1);
        storedMax=2^(T.WordLength-1)-1;
    else
        storedMin=0;
        storedMax=2^T.WordLength-1;
    end

    switch T.DataTypeMode
    case 'Fixed-point: binary point scaling'
        factor=1/(2^T.FractionLength);
        limits.realMin=storedMin*factor;
        limits.realMax=storedMax*factor;
    case 'Fixed-point: slope and bias scaling'
        limits.realMin=T.Slope*storedMin+T.Bias;
        limits.realMax=T.Slope*storedMax+T.Bias;
    otherwise
    end
end
