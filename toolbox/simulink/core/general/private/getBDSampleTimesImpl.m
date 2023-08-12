function sampleTimes = getBDSampleTimesImpl( mdlH )























needToThrowError = false;
caughtError = '';


if ( isstring( mdlH ) )
mdlH = convertStringsToChars( mdlH );
end 

try 
if ( ~strcmp( get_param( mdlH, 'Type' ), 'block_diagram' ) )

needToThrowError = true;
end 
catch caughtError
needToThrowError = true;
end 

if ( needToThrowError )
identifier = 'Simulink:utility:getSampleTimesNeedsBlockDiagram';
message = DAStudio.message( identifier );
me = MException( identifier, '%s', message );
if ( ~isempty( caughtError ) )
me = addCause( me, caughtError );
end 
throw( me );
end 

try 
sampleTimes = slprivate( 'slGetSampleTimes',  ...
get_param( mdlH, 'Name' ) );
catch e
identifier = 'Simulink:utility:BlockDiagramGetSampleTimesFailed';
message = DAStudio.message( identifier, get_param( mdlH, 'Name' ) );
me = MException( identifier, '%s', message );
me = addCause( me, e );
throw( me );

end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpRr9BUw.p.
% Please follow local copyright laws when handling this file.

