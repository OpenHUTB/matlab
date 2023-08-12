function [ status, result ] = runTargetsInSerial( runCmd, buildData )


R36
runCmd( 1, : )cell
buildData
end 
numRuns = numel( runCmd );

for i = 1:numRuns
cmd = runCmd{ i };
if buildData.opts.verbose
fprintf( '### %6.2fs :: Running process %i/%i with command line: %s\n', etime( clock, buildData.startTime ), i, numRuns, cmd );
else 
cmd = [ cmd, ' -verbose off' ];%#ok<AGROW> 
end 

if ispc
cmd = [ cmd, ' 1>nul' ];%#ok can't know size in advance.
else 
cmd = [ cmd, ' > /dev/null' ];%#ok
end 

[ status{ i }, result{ i } ] = system( cmd );%#ok<AGROW>
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpWRUPGM.p.
% Please follow local copyright laws when handling this file.

