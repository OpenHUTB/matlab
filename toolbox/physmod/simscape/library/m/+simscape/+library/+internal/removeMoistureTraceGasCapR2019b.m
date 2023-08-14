function removeMoistureTraceGasCapR2019b(block,portIndex)








    isLocked=get_param(bdroot,'Lock');
    set_param(bdroot,'Lock','off');

    if strcmp(get_param(block,'moisture_trace_gas_source'),'foundation.enum.moisture_trace_gas_source.controlled')

        connections=get_param(block,'PortConnectivity');
        dstPorts=connections(portIndex).DstPort;

        nonCapExists=false;
        for i=1:length(dstPorts)
            capBlock=get_param(dstPorts(i),'Parent');
            if~isempty(find_system(capBlock,'Regexp','on','SearchDepth','0','SourceFile','.*'))...
                &&strcmp(get_param(capBlock,'SourceFile'),'foundation.moist_air.sources.moisture_trace_gas.source_cap')
                delete_line(get_param(dstPorts(i),'Line'))
                delete_block(capBlock)
            else
                nonCapExists=true;
            end
        end

        if~nonCapExists
            set_param(block,'moisture_trace_gas_source','foundation.enum.moisture_trace_gas_source.none')
        end

    end


    set_param(bdroot,'Lock',isLocked);

end