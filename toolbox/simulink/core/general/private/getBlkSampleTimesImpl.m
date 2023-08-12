function sampleTimes = getBlkSampleTimesImpl( blkH )





















needToThrowError = false;
caughtError = '';


if ( isstring( blkH ) )
blkH = convertStringsToChars( blkH );
end 

try 
if ( ~strcmp( get_param( blkH, 'Type' ), 'block' ) )

needToThrowError = true;
end 
catch caughtError
needToThrowError = true;
end 

if ( needToThrowError )
identifier = 'Simulink:utility:getSampleTimesNeedsBlock';
message = DAStudio.message( identifier );
me = MException( identifier, '%s', message );
if ( ~isempty( caughtError ) )
me = addCause( me, caughtError );
end 
throw( me );
end 

try 
sampleTimes = slprivate( 'slGetSampleTimes', blkH );
catch e
identifier = 'Simulink:utility:BlockGetSampleTimesFailed';
message = DAStudio.message( identifier, getfullname( blkH ) );
me = MException( identifier, '%s', message );
me = addCause( me, e );
throw( me );
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp_FJeZD.p.
% Please follow local copyright laws when handling this file.

