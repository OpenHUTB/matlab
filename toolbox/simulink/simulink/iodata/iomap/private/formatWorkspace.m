function list = formatWorkspace( list )











isSignalClass = isSimulinkSignalClass( { list.class } );


if ~any( isSignalClass ) || isempty( { list.class } )

DAStudio.error( 'sl_inputmap:inputmap:apiBaseNoSignals' );
end 



list = list( isSignalClass );

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp0BVhPj.p.
% Please follow local copyright laws when handling this file.

