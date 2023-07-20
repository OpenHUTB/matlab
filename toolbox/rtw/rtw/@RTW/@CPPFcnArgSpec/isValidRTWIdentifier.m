function flag=isValidRTWIdentifier(hSrc)





    flag=true;

    argName=hSrc.ArgName;

    reservedRTWChars={'initialize','terminate','init','start','getRTM','setRTM'...
    ,'setBlockSignals','getBlockSignals','getDWork','setDWork'...
    ,'setContinuousStates','getContinuousStates','getZCEventData'...
    ,'setZCEventData','getBlockParameters','setBlockParameters'...
    ,'enable','disable'};

    temp=ismember(reservedRTWChars,argName);
    pos=find(temp,1);
    if~isempty(pos)
        flag=false;
        return;
    end




