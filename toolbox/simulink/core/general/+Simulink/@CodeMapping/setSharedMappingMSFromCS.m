function setSharedMappingMSFromCS( source, cs, csparam, mappingParam )




hlp = coder.internal.CoderDataStaticAPI.getHelper(  );
swct = coder.internal.CoderDataStaticAPI.getSWCT( source );

memSecForCategory = get_param( cs, csparam );
if ~isequal( memSecForCategory, 'Default' )
msName = memSecForCategory;
cdict = hlp.openDD( source );
ms = hlp.findEntry( cdict, 'MemorySection', msName );
dc = hlp.getProp( swct, mappingParam );
hlp.setProp( dc, 'InitialMemorySection', ms );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpx5ss6J.p.
% Please follow local copyright laws when handling this file.

