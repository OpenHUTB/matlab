function[status,cmdout]=simulationEngineWrapper(command)

    tokenVar='SIT_simulation_token';
    if isempty(getenv('SIT_license_disable_simulation'))
        token=siCurrentTokenString();
    else

        token='SIT_license_disable_simulationINVALIDTKN';
    end
    if strcmp(command,tokenVar)
        status=0;
        cmdout=token;
    else

        builtin('setenv',tokenVar,token);
        try
            [status,cmdout]=system(command);
        catch ME
            status=-5;
            cmdout=ME.message;
        end
        builtin('setenv',tokenVar);
    end
end


function token=siCurrentTokenString()
    dt=datetime('now');
    setNumber=111+dt.Day+dt.Month*40+dt.Year*381;
    timeNumber=floor(dt.Second*1000)+(60000*((60*dt.Minute)+dt.Hour));
    tokenIndexMax=2000;
    tokenIndex=1+mod(timeNumber,tokenIndexMax);
    token=siTokenString(setNumber,tokenIndex);
end


function token=siTokenString(setNumber,tokenIndex)
    charMap=[48:57,65:90,97:122];
    charMapLen=length(charMap);
    tokenLen=40;
    rngSave=rng;
    rng(setNumber,'twister');
    for i=1:((tokenIndex-1)*tokenLen)
        randi(charMapLen,1,1);
    end
    token=char(charMap(randi(charMapLen,1,tokenLen)));
    rng(rngSave);
end


