function setPortImplParams(this,hPort,isTopNetworkPort)




    this.setPortImplParams@hdldefaults.AbstractPort(hPort,isTopNetworkPort);


    if isTopNetworkPort
        convertPort=this.getImplParams('ConvertToSamples');

        if~isempty(convertPort)
            assert(strcmp(convertPort,'on'));
            hPort.getStreamingMatrixTag;
        end
    end
end
