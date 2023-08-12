function validateSignalValue( signalValue )





if ( ~iscell( signalValue ) && ~iofile.Util.isValidSignal( signalValue ) ) ||  ...
( ( iscell( signalValue ) && isempty( signalValue ) ) || ( iscell( signalValue ) && ~all( cellfun( @iofile.Util.isValidSignal, signalValue ) ) ) )

DAStudio.error( 'sl_inputmap:inputmap:apiSignalValue' );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpG89VZf.p.
% Please follow local copyright laws when handling this file.

