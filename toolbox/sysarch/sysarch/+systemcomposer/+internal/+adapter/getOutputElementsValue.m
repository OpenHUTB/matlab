function val = getOutputElementsValue( blkH )







outBlks = find_system( blkH, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'BlockType', 'Outport' );
val = cell( length( outBlks ), 1 );
for cnt = 1:length( outBlks )
outBlk = outBlks( cnt );
outName = get_param( outBlk, 'PortName' );
elemName = get_param( outBlks( cnt ), 'Element' );
if ~isempty( elemName )
val{ cnt } = [ outName, '.', elemName ];
else 
val{ cnt } = outName;
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpTSrsGw.p.
% Please follow local copyright laws when handling this file.

