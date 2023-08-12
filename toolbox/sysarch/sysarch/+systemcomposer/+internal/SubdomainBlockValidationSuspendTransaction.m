classdef SubdomainBlockValidationSuspendTransaction < handle





properties 
bd;
end 

methods 
function this = SubdomainBlockValidationSuspendTransaction( modelNameOrHandle )
this.bd = modelNameOrHandle;
set_param( modelNameOrHandle, 'SuspendBlockValidation', 'on' );
Simulink.SystemArchitecture.internal.ApplicationManager.disableModelConsistencyCheck( get_param( this.bd, 'Handle' ) );
end 

function delete( this )
modelName = get_param( this.bd, 'Name' );
if ( bdIsLoaded( modelName ) )
Simulink.SystemArchitecture.internal.ApplicationManager.enableModelConsistencyCheck( get_param( this.bd, 'Handle' ) );
set_param( this.bd, 'SuspendBlockValidation', 'off' );
systemcomposer.internal.arch.internal.processBatchedPluginEvents( get_param( this.bd, 'Handle' ) );
end 
end 

function commit( this )
delete( this );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp3rbnw1.p.
% Please follow local copyright laws when handling this file.

