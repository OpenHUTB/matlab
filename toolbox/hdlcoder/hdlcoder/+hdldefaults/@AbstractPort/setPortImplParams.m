function setPortImplParams(this,hPort,isTopNetworkPort)









    isbidi=this.getImplParams('BidirectionalPort');
    hPort.setBidirectional(~isempty(isbidi)&&strcmpi(isbidi,'on'));

    if isTopNetworkPort
        IOInterface=this.getImplParams('IOInterface');
        if~isempty(IOInterface)
            hPort.setIOInterface(IOInterface);
        end
        IOInterfaceMapping=this.getImplParams('IOInterfaceMapping');
        if~isempty(IOInterfaceMapping)
            hPort.setIOInterfaceMapping(IOInterfaceMapping);
        end
    end


end
