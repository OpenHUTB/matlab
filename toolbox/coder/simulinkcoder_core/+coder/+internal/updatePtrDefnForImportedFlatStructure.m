function ret = updatePtrDefnForImportedFlatStructure( typeDef, dataDecl, dataDef )
















searchRegExp = '((?<=(^|\n))[^;]*)\s+(\*)(\w+)(;)';
replaceRegExp = '$1 $3_csc_storage;\n$1 $2$3 = &$3_csc_storage;';
dataDef =  ...
regexprep( dataDef, searchRegExp, replaceRegExp );
ret = coder.internal.escapeValuesFromTLCForCodeDescriptor( typeDef, dataDecl, dataDef );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpAG4Q_F.p.
% Please follow local copyright laws when handling this file.

