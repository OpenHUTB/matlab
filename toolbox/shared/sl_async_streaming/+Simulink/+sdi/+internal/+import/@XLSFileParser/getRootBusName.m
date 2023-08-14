function[rootBusName,remainingSigName]=getRootBusName(this,busName)
    if busName(1)=='.'
        rootBusName='';
        remainingSigName=busName(2:end);
    else
        rootBusNameLength=regexp(busName,this.BusRx);
        rootBusName=busName(1:rootBusNameLength);
        remainingSigName=busName(rootBusNameLength+2:end);
    end
end