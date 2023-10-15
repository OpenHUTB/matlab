function maskTreeAndModel = getMaskTreeAndModel( modelName )

arguments
    modelName( 1, 1 )string
end

maskTreeFilePath = simulink.rapidaccelerator.internal.getMaskTreeFilePath( modelName );
parser = mf.zero.io.XmlParser;
maskTree = parser.parseFile( maskTreeFilePath );
maskTreeAndModel = struct( 'maskTree', maskTree, 'model', parser.Model );
end

