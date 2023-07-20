function[inPutDataWidth,outPutDataWidth]=getIOBitWidth(this,BuildInfo)%#ok<INUSL>
    inPutDataWidth=0;
    outPutDataWidth=0;
    byteAlign=true;
    dutPorts=BuildInfo.DUTPorts;
    for i=1:length(dutPorts.PortName)
        if~strcmpi(dutPorts.PortType{i},'Clock')&&~strcmpi(dutPorts.PortType{i},'Reset')&&~strcmpi(dutPorts.PortType{i},'Clock enable')
            if strcmpi(dutPorts.PortDirection{i},'In')&&(strcmpi(dutPorts.PortConnectivity{i},'Drive')||isempty(dutPorts.PortConnectivity{i}))
                if~byteAlign
                    inPutDataWidth=inPutDataWidth+dutPorts.PortWidth{i};
                else
                    if mod(dutPorts.PortWidth{i},8)==0
                        noOfBytes=floor(dutPorts.PortWidth{i}/8);
                    else
                        noOfBytes=floor(dutPorts.PortWidth{i}/8)+1;
                    end
                    inPutDataWidth=inPutDataWidth+noOfBytes*8;
                end
            elseif strcmpi(dutPorts.PortDirection{i},'Out')&&(strcmpi(dutPorts.PortConnectivity{i},'Capture')||isempty(dutPorts.PortConnectivity{i}))
                if~byteAlign
                    outPutDataWidth=outPutDataWidth+dutPorts.PortWidth{i};
                else
                    if mod(dutPorts.PortWidth{i},8)==0
                        noOfBytes=floor(dutPorts.PortWidth{i}/8);
                    else
                        noOfBytes=floor(dutPorts.PortWidth{i}/8)+1;
                    end
                    outPutDataWidth=outPutDataWidth+noOfBytes*8;
                end
            end
        end
    end
end