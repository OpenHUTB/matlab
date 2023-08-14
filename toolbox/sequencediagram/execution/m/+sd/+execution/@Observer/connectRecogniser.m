function connectRecogniser(obj,recogniser)





    for port=recogniser.data.toArray
        if isa(port,'sd.execution.Port')

            source=port.source;
            portString=string(recogniser.chart.Name)+"/"+string(port.portNumber);
            if isa(port,'sd.execution.DataPort')||isa(source,'sd.execution.MessageEventSource')
                if isa(source,'sd.execution.MessageEventSource')&&source.ports.Size>1
                    if(port.isStart)
                        add_line(obj.name,source.receiveSourcePort,portString);
                    else
                        add_line(obj.name,source.sendSourcePort,portString);
                    end
                else
                    add_line(obj.name,source.sourcePort,portString);
                end

            else
                if(port.isStart)
                    add_line(obj.name,source.sendSourcePort,portString);
                else
                    add_line(obj.name,source.receiveSourcePort,portString);
                end
            end
        end
    end

    verdictPortString=string(recogniser.chart.Name)+"/"+string(recogniser.verdictPort.portNumber);
    add_line(obj.name,verdictPortString,"verdict/1");
    warningPortString=string(recogniser.chart.Name)+"/"+string(recogniser.warningPort.portNumber);
    add_line(obj.name,warningPortString,"warnings/1");
end
