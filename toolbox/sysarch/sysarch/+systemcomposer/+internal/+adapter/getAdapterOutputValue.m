function val = getAdapterOutputValue( blkH )







inBlks = find_system( blkH, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'BlockType', 'Inport' );
val = cell( length( inBlks ), 1 );

for cnt = 1:length( inBlks )
inBlk = inBlks( cnt );



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

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpmZ3q3T.p.
% Please follow local copyright laws when handling this file.

