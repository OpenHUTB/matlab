function validateMappingMode( mode )




valid_modes = Simulink.iospecification.BuiltInMapModes.getBuiltInModes;

if isstring( mode ) && isscalar( mode )
mode = char( mode );
elseif isstring( mode ) && ~isscalar( mode )
DAStudio.error( 'sl_inputmap:inputmap:apiMappingModeValue' );
end 

if ~ischar( mode ) || ~any( strcmpi( valid_modes, mode ) )
DAStudio.error( 'sl_inputmap:inputmap:apiMappingModeValue' );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpTJc0lI.p.
% Please follow local copyright laws when handling this file.

