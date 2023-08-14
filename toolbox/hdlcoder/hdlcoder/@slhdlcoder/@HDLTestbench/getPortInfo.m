
function portData=getPortInfo(~,hPir,outPortLatency)

    portData=struct('Name','','Index',0,'Direction','','Kind','','TypeInfo',{},'Rate',0,'Latency',0);

    topNtwk=hPir.getTopNetwork;
    for ii=1:topNtwk.NumberOfPirInputPorts
        pirPort=topNtwk.PirInputPorts(ii);
        pirPortSignal=pirPort.Signal;

        portInfo.Name=pirPort.Name;
        portInfo.Index=pirPort.PortIndex;
        portInfo.Direction='Input';
        portInfo.Kind=pirPort.Kind;
        portInfo.TypeInfo=pirgetdatatypeinfo(pirPortSignal.Type);
        portInfo.Rate=pirPortSignal.SimulinkRate;
        portInfo.Latency=-1;

        portData(end+1)=portInfo;%#ok<AGROW>
    end


    for ii=1:topNtwk.NumberOfPirOutputPorts
        pirPort=topNtwk.PirOutputPorts(ii);
        pirPortSignal=pirPort.Signal;
        portInfo.Name=pirPort.Name;
        portInfo.Index=pirPort.PortIndex;
        portInfo.Direction='Output';
        portInfo.Kind=pirPort.Kind;
        portInfo.TypeInfo=pirgetdatatypeinfo(pirPortSignal.Type);
        portInfo.Rate=pirPortSignal.SimulinkRate;
        portInfo.Latency=outPortLatency;
        portData(end+1)=portInfo;%#ok<AGROW>
    end
end
