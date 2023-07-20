function resetMaxMinHoldStates(obj,type)




    if strcmp(obj.ChannelMode,'All')
        nChan=obj.pNumChannels;
    else
        nChan=1;
    end
    if nargin==1
        obj.pMaxHoldPSD=-inf*ones(obj.pFreqVectLength,nChan);
        obj.pMinHoldPSD=inf*ones(obj.pFreqVectLength,nChan);
    elseif strcmp(type,'MaxHoldTrace')
        obj.pMaxHoldPSD=-inf*ones(obj.pFreqVectLength,nChan);
    elseif strcmp(type,'MinHoldTrace')
        obj.pMinHoldPSD=inf*ones(obj.pFreqVectLength,nChan);
    end
end
