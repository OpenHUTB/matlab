

function deregister(name)

    if(nargin~=1||~ischar(name))
        errid='Simulink:Bus:BusDeRegisterInvalidInputArgs';
        me=MException(errid,DAStudio.message(errid));
        throwAsCaller(me);
    end


    busDict=Simulink.BusDictionary.getInstance();
    busDict.deleteRegisteredBusType(name);
    busDict.deleteRegisteredBusOrigin(name);
end
