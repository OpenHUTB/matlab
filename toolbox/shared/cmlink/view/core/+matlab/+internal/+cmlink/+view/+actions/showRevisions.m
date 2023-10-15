function showRevisions( file, commandExecutor )

import matlab.internal.cmlink.view.CommandExecutor;
if nargin < 2
    commandExecutor = CommandExecutor(  );
end
iRunCommand( file, commandExecutor );

end

function iRunCommand( file, commandExecutor )
arguments
    file{ mustBeFile }
    commandExecutor
end
commandExecutor.run( 'log', file );
end


