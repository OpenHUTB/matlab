function maskTreeAndModel = getMaskTreeAndModel( modelName )







R36
modelName( 1, 1 )string
end 

maskTreeFilePath = simulink.rapidaccelerator.internal.getMaskTreeFilePath( modelName );
parser = mf.zero.io.XmlParser;
maskTree = parser.parseFile( maskTreeFilePath );
maskTreeAndModel = struct( 'maskTree', maskTree, 'model', parser.Model );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpThlx81.p.
% Please follow local copyright laws when handling this file.

