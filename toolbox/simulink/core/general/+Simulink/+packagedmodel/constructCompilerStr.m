function result = constructCompilerStr( comp )

arguments
    comp{ mustBeA( comp, { 'mex.CompilerConfiguration', 'struct' } ) }
end

fields = loc_getFields( comp );
if loc_hasField( fields, 'Version' ) && loc_hasField( fields, 'Name' )
    result = sprintf( '%s v%s', comp.Name, comp.Version );
elseif loc_hasField( fields, 'Name' )
    result = comp.Name;
else
    result = '';
end
end

function fields = loc_getFields( comp )
if isstruct( comp )
    fields = fieldnames( comp );
else
    fields = properties( comp );
end
end

function result = loc_hasField( fields, field )
result = any( contains( fields, field ) );
end


