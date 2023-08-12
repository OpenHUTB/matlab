function tf = isSubsystemReferencePort( archPort )




R36
archPort{ mustBeA( archPort, { 'systemcomposer.arch.ArchitecturePort', 'systemcomposer.architecture.model.design.ArchitecturePort' } ) }
end 
if isa( archPort, 'systemcomposer.arch.ArchitecturePort' )
archPort = archPort.getImpl;
end 

parentArch = archPort.getContainingArchitecture;
if parentArch.hasParentComponent
tf = parentArch.getParentComponent.isSubsystemReferenceComponent;
else 

portHandles = systemcomposer.utils.getSimulinkPeer( archPort );
bdHandle = bdroot( portHandles( 1 ) );
tf = strcmp( get_param( bdHandle, 'BlockDiagramType' ), 'subsystem' );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpsCjgLh.p.
% Please follow local copyright laws when handling this file.

