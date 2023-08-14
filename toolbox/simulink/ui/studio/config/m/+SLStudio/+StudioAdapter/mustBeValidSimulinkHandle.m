function mustBeValidSimulinkHandle(blockHandle)
    isValid=ishandle(blockHandle);
    if isValid
        r=Simulink.Root;
        isValid=r.isValidSlObject(blockHandle);
    end

    if~isValid
        errorID='Simulink:utility:invalidHandle';
        messageObject=message(errorID);
        E=MException(errorID,messageObject.getString);
        throwAsCaller(E);
    end
end