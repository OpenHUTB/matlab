function showRevisions( file, commandExecutor )






import matlab.internal.cmlink.view.CommandExecutor;
if nargin < 2
commandExecutor = CommandExecutor(  );
end 
iRunCommand( file, commandExecutor );

end 

function iRunCommand( file, commandExecutor )
R36
file{ mustBeFile }
commandExecutor
end 
commandExecutor.run( 'log', file );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpStKOgC.p.
% Please follow local copyright laws when handling this file.

