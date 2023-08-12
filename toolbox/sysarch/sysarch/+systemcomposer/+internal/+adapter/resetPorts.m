function resetPorts( blkHdl )








inports = find_system( blkHdl, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'BlockType', 'Inport' );
outports = find_system( blkHdl, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'BlockType', 'Outport' );
delete_block( inports );
delete_block( outports );


add_block( 'simulink/Ports & Subsystems/In Bus Element', [ getfullname( blkHdl ), '/In Bus Element' ], 'PortName', 'In' );
add_block( 'simulink/Ports & Subsystems/Out Bus Element', [ getfullname( blkHdl ), '/Out Bus Element' ], 'PortName', 'Out' );


systemcomposer.internal.adapter.setMappings( blkHdl, { 'In' }, { 'Out' } );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpjjmkAI.p.
% Please follow local copyright laws when handling this file.

