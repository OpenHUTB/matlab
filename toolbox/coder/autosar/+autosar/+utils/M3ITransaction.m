classdef M3ITransaction < handle





properties ( Access = private )
LocalTransaction;
SharedTransaction;
LocalM3IModel;
SharedM3IModel;
DisableListeners;
RestoreLocalM3IModelListener = onCleanup.empty;
RestoreSharedM3IModelListener = onCleanup.empty;
end 

methods 
function this = M3ITransaction( m3iModelLocal, namedargs )
R36
m3iModelLocal Simulink.metamodel.foundation.Domain
namedargs.DisableListeners = false;
end 

this.LocalTransaction = M3I.Transaction( m3iModelLocal );
this.LocalM3IModel = m3iModelLocal;

if autosar.dictionary.Utils.hasReferencedModels( m3iModelLocal )
this.SharedM3IModel = autosar.dictionary.Utils.getUniqueReferencedModel( m3iModelLocal );
this.SharedTransaction = M3I.Transaction( this.SharedM3IModel );
else 
this.SharedTransaction = [  ];
end 
this.DisableListeners = namedargs.DisableListeners;
end 

function commit( this )
if this.DisableListeners
this.RestoreLocalM3IModelListener = autosarcore.unregisterListenerCBTemporarily( this.LocalM3IModel );
if ~isempty( this.SharedTransaction )
this.RestoreSharedM3IModelListener = autosarcore.unregisterListenerCBTemporarily( this.SharedM3IModel );
end 
end 

this.LocalTransaction.commit(  );
if ~isempty( this.SharedTransaction )
this.SharedTransaction.commit(  );
this.RestoreSharedM3IModelListener.delete(  );
end 
this.RestoreLocalM3IModelListener.delete(  );
end 

function cancel( this )
this.LocalTransaction.cancel(  );
if ~isempty( this.SharedTransaction )
this.SharedTransaction.cancel(  );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmptFSe9Q.p.
% Please follow local copyright laws when handling this file.

