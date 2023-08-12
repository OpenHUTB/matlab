classdef SLSubsystemToAdapterConverter < handle




properties 
suspendBlockValidationTxn;
newBlockHdl = [  ];
end 

methods 
function this = SLSubsystemToAdapterConverter( srcBlk, targetbd, targetBlk )



assert( ischar( srcBlk ) && bdIsLoaded( targetbd ) && ischar( targetBlk ) );
this.suspendBlockValidationTxn = systemcomposer.internal.SubdomainBlockValidationSuspendTransaction( targetbd );
this.newBlockHdl = add_block( srcBlk, targetBlk, 'MakeNameUnique', 'on' );
this.setSimulinkSubDomainToAdapterDomain( this.newBlockHdl );
systemcomposer.internal.arch.internal.processBatchedPluginEvents( targetbd );
end 

function delete( this )
delete( this.suspendBlockValidationTxn );
end 
end 
methods ( Static = true, Access = private )
function setSimulinkSubDomainToAdapterDomain( ssBlock )
graphHandle = get_param( ssBlock, 'handle' );
SimulinkSubDomainMI.SimulinkSubDomain.setSimulinkSubDomain( graphHandle, SimulinkSubDomainMI.SimulinkSubDomainEnum.ArchitectureAdapter );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpNgdCL9.p.
% Please follow local copyright laws when handling this file.

