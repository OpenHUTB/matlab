function schema = pmsl_updatedialogschema( schema, widget, path );





if isempty( path )
schema = widget;
else 
schema.Items{ path( 1 ) } = pmsl_updatedialogschema( schema.Items{ path( 1 ) }, widget, path( 2:end  ) );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp48MEQO.p.
% Please follow local copyright laws when handling this file.

