function ports = traceBlockPorts( block, portType, NVOptions )

arguments
    block{ slreportgen.report.validators.mustBeSimulinkObject }
    portType{ mustBeMember( portType, [ "Inport", "Outport", "Enable", "Trigger", "State", "Ifaction", "Reset" ] ) } = "Inport"
    NVOptions.PortNumber{ mustBeInteger, mustBeGreaterThan( NVOptions.PortNumber, 0 ) } = [  ]
    NVOptions.Nonvirtual logical = false
end


ph = get_param( block, "PortHandles" );

toTrace = ph.( portType );

portNum = NVOptions.PortNumber;
if ~isempty( portNum )
    if portNum > numel( toTrace )
        ports = [  ];
        return ;
    end
    toTrace = toTrace( portNum );
end

[ ~, portsCell, ~ ] = slreportgen.utils.traceSignal( toTrace, "Nonvirtual", NVOptions.Nonvirtual );

if iscell( portsCell )
    ports = cell2mat( portsCell );
else
    ports = portsCell;
end

end


