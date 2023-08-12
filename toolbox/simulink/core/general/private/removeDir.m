function removeDir( dname )










oldWarning = warning( 'off', 'MATLAB:RMDIR:RemovedFromPath' );
cl = onCleanup( @(  )warning( oldWarning.state, 'MATLAB:RMDIR:RemovedFromPath' ) );

for i = 1:100
try 
builtin( 'rmdir', dname, 's' );
return ;
catch exc














if ~ismember( exc.identifier,  ...
{ 'MATLAB:RMDIR:NoDirectoriesRemoved' ...
, 'MATLAB:RMDIR:NotADirectory' ...
, 'MATLAB:RMDIR:SomeDirectoriesNotRemoved' } )
rethrow( exc );
end 


if strcmp( exc.identifier, 'MATLAB:RMDIR:NotADirectory' )
return ;
end 

if ( i == 100 )
return ;
end 

pause( 0.1 );


end 
end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpFKxujI.p.
% Please follow local copyright laws when handling this file.

