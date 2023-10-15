function editor( allocSet )

arguments
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
