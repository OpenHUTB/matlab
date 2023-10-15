function success = generateInterfaceHeader( self, options )

arguments
    self( 1, 1 )polyspace.internal.codeinsight.CodeInfo
    options.CodeInsightObj( 1, 1 )polyspace.internal.codeinsight.CodeInsight
    options.OutputFile( 1, 1 )string
    options.IsPreprocessed( 1, 1 )logical = false
end

fInfoList = self.CodeInsightInfo.Functions.toArray;
if ~isempty( fInfoList )
    fList = [ fInfoList.Function ];

    fInfoList = fInfoList( [ fList.IsCompilerGenerated ] == false );
end
if ~isempty( fInfoList )

    fInfoList = fInfoList( [ fInfoList.IsDefined ] == true );
    if ~isempty( fInfoList )
        if options.IsPreprocessed






            fInfoList = fInfoList( [ fInfoList.IsDeclared ] == true );
        else
            fInfoList = fInfoList( [ fInfoList.IsDeclaredInHeader ] == true );
        end
    else
        fInfoList = [  ];
    end
end

assert( self.hasSLCCCompliantInfo, "Interface header file requires SLCC compliant info" );

isSLCCCompliant = polyspace.internal.codeinsight.CodeInfo.isSLCCImportCompliant( fInfoList, options.IsPreprocessed );



if ~isempty( fInfoList )
    fInfoFcnList = [ fInfoList.Function ];
else
    fInfoFcnList = [  ];
end
if polyspace.internal.codeinsight.utils.codeInsightFeature( "PSPreProcessedFile" )

    isLibFcn = arrayfun( @( x )polyspace.internal.codeinsight.utils.isLibFunction( x.Name ), fInfoFcnList );
else
    isLibFcn = false( size( fInfoFcnList ) );
end


fInfoList = fInfoList( isSLCCCompliant & ~isLibFcn );
if ~isempty( fInfoList )
    fInfoFcnList = [ fInfoList.Function ];
else
    fInfoFcnList = [  ];
end
funDeclList = arrayfun( @( x )polyspace.internal.codeinsight.CodeInfo.generateFunctionSignature( x, "" ), fInfoFcnList );
funDeclListStr = "";
if ~isempty( funDeclList )
    functionHeader =  ...
        "/*************************************************************************/" + newline +  ...
        "/* Function declarations                                                 */" + newline +  ...
        "/*************************************************************************/" + newline;
    funDeclListStr = functionHeader + join( funDeclList, ";" + newline ) + ";" + newline;
end

typeList = internal.cxxfe.ast.types.Type.empty(  );
if ~isempty( fInfoList )

    fList = [ fInfoList.Function ];
    for fIdx = 1:numel( fList )
        paramList = fList( fIdx ).Params.toArray;
        if ~isempty( paramList )
            typeList = [ typeList, paramList.Type ];%#ok<AGROW>
        end
        typeList = [ typeList, fList( fIdx ).Type.RetType ];%#ok<AGROW>
    end
end

vInfoList = self.CodeInsightInfo.Variables.toArray;
if ~isempty( vInfoList )
    if options.IsPreprocessed
        vInfoList = vInfoList( [ vInfoList.IsDefined ] == true & [ vInfoList.IsDeclared ] == true );
    else
        vInfoList = vInfoList( [ vInfoList.IsDefined ] == true & [ vInfoList.IsDeclaredInHeader ] == true );
    end
end
if ~isempty( vInfoList )
    isSLCCCompliant = polyspace.internal.codeinsight.CodeInfo.isSLCCImportCompliant( vInfoList, options.IsPreprocessed );
    vInfoList = vInfoList( isSLCCCompliant );
end

if ~isempty( vInfoList )
    vVariableList = [ vInfoList.Variable ];
else
    vVariableList = [  ];
end
varDeclList = arrayfun( @( x )( "extern " + polyspace.internal.codeinsight.CodeInfo.generateTypeName( x.Type, x.Name ) ), vVariableList );
varDeclListStr = "";
if ( ~isempty( varDeclList ) )
    variableHeader =  ...
        "/*************************************************************************/" + newline +  ...
        "/* Global Variable declarations                                          */" + newline +  ...
        "/*************************************************************************/" + newline;
    varDeclListStr = variableHeader + join( varDeclList, ";" + newline ) + ";" + newline;
end

if ~isempty( vVariableList )
    typeList = [ typeList, [ vVariableList.Type ] ];
end

[ ~, IA, ~ ] = unique( string( { typeList.UUID } ), 'stable' );
typeList = typeList( IA );






typeDefs = options.CodeInsightObj.getTypeDefinitions( typeList );

stripTypeDefs = arrayfun( @( x )strjoin( strip( splitlines( x ) ), newline ), typeDefs );
[ ~, IA, ~ ] = unique( stripTypeDefs, 'stable' );
typeDefs = typeDefs( IA );
typeDefsStr = "";
if ~isempty( typeDefs )
    typeHeader =  ...
        "/*************************************************************************/" + newline +  ...
        "/* Type definitions                                                      */" + newline +  ...
        "/*************************************************************************/" + newline;
    typeDefsStr = typeHeader + join( typeDefs, newline );
end

commentHeader =  ...
    "/*************************************************************************/" + newline +  ...
    "/* Interface header file to be used for Simulink Custom Code interface.  */" + newline +  ...
    "/* Automatically generated " + string( datestr( now ) ) + "                          */" + newline +  ...
    "/* No modification to the content of this file should be done.           */" + newline +  ...
    "/* This file should not be included in any source file.                  */" + newline +  ...
    "/*************************************************************************/" + newline + newline;

headerContent = commentHeader + newline +  ...
    typeDefsStr + newline +  ...
    varDeclListStr + newline +  ...
    funDeclListStr + newline;

fid = fopen( options.OutputFile, 'w' );
fprintf( fid, "%s", headerContent );
fclose( fid );


c_beautifier( char( options.OutputFile ) );


cObj = polyspace.internal.codeinsight.CodeInsight( 'SourceFiles', options.OutputFile );
success = cObj.parse;
if ~success
    error( string( cObj.Errors ) );
end

end

