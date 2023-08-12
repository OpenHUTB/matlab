function report = dispAdapterMappings( blkHdl )






inports = find_system( blkHdl, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'BlockType', 'Inport' );
numMappings = length( inports );

report = cell2table( cell( numMappings, 2 ), 'VariableNames', { 'InputElements', 'OutputElements' } );

for idx = 1:numMappings
inp = inports( idx );
ph = get_param( inp, 'LineHandles' );
out = get_param( ph.Outport, 'DstBlockHandle' );

inpPath = getElemPath( inp );
outPath = getElemPath( out );

report( idx, : ) = { inpPath, outPath };
end 

function name = getElemPath( bep )

name = get_param( bep, 'PortName' );
elem = get_param( bep, 'Element' );
if ~isempty( elem )
name = [ name, '.', elem ];
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpbAghW8.p.
% Please follow local copyright laws when handling this file.

