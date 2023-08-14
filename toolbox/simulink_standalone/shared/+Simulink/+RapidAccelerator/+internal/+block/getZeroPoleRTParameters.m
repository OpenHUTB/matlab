function[A,B,C,D]=getZeroPoleRTParameters(z,p,k)






    [nZRows,nZCols]=size(z);
    if(nZCols==1||nZRows==1)
        nOutputs=1;
    else
        nOutputs=nZCols;
    end
    if(nOutputs==0)
        nOutputs=length(k);
    end
    if(length(k)==1&&nOutputs~=1)
        gain=k;
        k(1:nOutputs)=gain;
    end

    try
        [A,B,C,D]=zp2ss(z,p,k);
    catch causeException

        baseException=MException('SimulinkBlocks:ZeroPole:InconsistentParameterSettings',...
        message('SimulinkBlocks:ZeroPole:InconsistentParameterSettings'));
        baseException=addCause(baseException,causeException);
        throwAsCaller(baseException);
    end
end


