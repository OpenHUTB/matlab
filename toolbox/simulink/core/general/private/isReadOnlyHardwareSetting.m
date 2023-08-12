function isReadOnly = isReadOnlyHardwareSetting( hwDevice, fieldName )




isReadOnly = true;

hh = targetrepository.getHardwareImplementationHelper(  );

device = hh.getDevice( hwDevice );

if ~isempty( device ) && isa( device, 'target.internal.Processor' )

impl = hh.getImplementation( device );
isReadOnly = ~impl.getIsEnabled( fieldName );
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpEW5Ld_.p.
% Please follow local copyright laws when handling this file.

