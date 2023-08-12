function [ inputs, outputs ] = getMappings( blkHdl )






inports = find_system( blkHdl, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'BlockType', 'Inport' );
[ inputs, connectedInports ] = getMappingInputs( inports );

outports = getConnectedOutputs( connectedInports );
outputs = getMappingOutputs( outports );

end 

function [ val, connectedInports ] = getMappingInputs( inports )



val = cell( length( inports ), 1 );

for cnt = 1:length( inports )
inBlk = inports( cnt );



lh = get_param( inBlk, 'LineHandles' );
if ~ishandle( lh.Outport ) || strcmpi( get_param( lh.Outport, 'Connected' ), 'off' )
continue ;
end 

portName = get_param( inBlk, 'PortName' );
elemName = get_param( inBlk, 'Element' );
if ~isempty( elemName )
val{ cnt } = [ portName, '.', elemName ];
else 
val{ cnt } = portName;
end 
end 

emptyIdx = cellfun( @isempty, val );
val( emptyIdx ) = [  ];

connectedInports = inports( ~emptyIdx );

end 

function outports = getConnectedOutputs( inports )

outports = cell( size( inports ) );
for idx = 1:length( inports )
input = inports( idx );
ports = get_param( input, 'PortHandles' );
line = get_param( ports.Outport, 'Line' );
dstBlock = get_param( line, 'DstBlockHandle' );
outports{ idx } = getfullname( dstBlock );
end 

end 

function outputs = getMappingOutputs( outports )

outputs = cell( size( outports ) );

for idx = 1:length( outports )
outport = outports{ idx };
portName = get_param( outport, 'PortName' );
elemName = get_param( outport, 'Element' );
if isempty( elemName )
outputs{ idx } = portName;
else 
outputs{ idx } = [ portName, '.', elemName ];
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpCkHte6.p.
% Please follow local copyright laws when handling this file.

