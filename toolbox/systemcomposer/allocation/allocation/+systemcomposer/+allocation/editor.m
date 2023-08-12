function editor( allocSet )












R36
allocSet = ''
end 

if isa( allocSet, 'systemcomposer.allocation.AllocationSet' ) && ~isempty( allocSet )
allocSet = allocSet.Name;
elseif ~ischar( allocSet ) && ~isStringScalar( allocSet )
allocSet = '';
end 

appCatalog = systemcomposer.allocation.app.AllocationAppCatalog.getInstance;
appCatalog.openStudio( false, allocSet );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp0vut9k.p.
% Please follow local copyright laws when handling this file.

