function updateLibForModelRefCopy( obj )




[ libName, libfullPath ] = Sldv.xform.BlkReplacer.createUniqueLibName(  ...
obj.MdlInfo.OrigModelH, obj.TestComponent, obj.SldvOptConfig );
Sldv.xform.BlkReplacer.createLib( obj.MdlInfo.ModelH, libName,  ...
libfullPath );
obj.LibForModelRefCopy = libName;
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmptSQMLG.p.
% Please follow local copyright laws when handling this file.

