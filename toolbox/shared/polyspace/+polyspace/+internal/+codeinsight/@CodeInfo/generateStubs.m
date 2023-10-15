function [ success, headerContent, sourceContent ] = generateStubs( self, options )

arguments
    self( 1, 1 )polyspace.internal.codeinsight.CodeInfo
    options.Metadata( 1, 1 )polyspace.internal.codeinsight.utils.Metadata = [  ]
    options.CodeInsightObj( 1, 1 )polyspace.internal.codeinsight.CodeInsight
    options.AddOriginalIncludeList( 1, 1 )logical = false
end
success = true;
self.checkObject(  );
fInfoList = self.CodeInsightInfo.Functions.toArray;
if ~isempty( fInfoList )
    fList = [ fInfoList.Function ];

    fInfoList = fInfoList( [ fList.IsCompilerGenerated ] == false );
end
if ~isempty( fInfoList )
    undefinedFunctions = fInfoList( [ fInfoList.IsDefined ] == false );
else
    undefinedFunctions = [  ];
end
if ~isempty( undefinedFunctions )
    undefinedAndUndeclaredFunctions = undefinedFunctions( [ undefinedFunctions.IsDeclared ] == false );
else
    undefinedAndUndeclaredFunctions = [  ];
end
if ~isempty( undefinedAndUndeclaredFunctions )
    fList = [ undefinedAndUndeclaredFunctions.Function ];
    warningState = warning( 'off', 'backtrace' );
    ls1 = length( fList );
    [ name{ 1:ls1 } ] = deal( fList.Name );

    self.MissingFunctionDeclaration = name;
    x = strjoin( name, ", " );
    m = message( 'cxxfe:codeinsight:MissingFuncDeclaration', x, newline );
    warning( m );
    warning( warningState );
end


if ~isempty( undefinedFunctions )
    undefinedFunctions = undefinedFunctions( [ undefinedFunctions.IsDeclared ] == true & ( [ undefinedFunctions.IsCalled ] == true | [ undefinedFunctions.IsAddressTaken ] == true ) );
end
if ~isempty( undefinedFunctions )
    undefinedFunctionsFcn = [ undefinedFunctions.Function ];
else
    undefinedFunctionsFcn = [  ];
end

if ~isempty( undefinedFunctionsFcn )

    isUndefinedLibFcn = arrayfun( @( x )polyspace.internal.codeinsight.utils.isLibFunction( x.Name ), undefinedFunctionsFcn );
    undefinedFunctions = undefinedFunctions( ~isUndefinedLibFcn );
    undefinedFunctionsFcn = undefinedFunctionsFcn( ~isUndefinedLibFcn );
end




if polyspace.internal.codeinsight.utils.codeInsightFeature( "PSPreProcessedFile" )

    isLibFcn = arrayfun( @( x )polyspace.internal.codeinsight.utils.isLibFunction( x.Name ), undefinedFunctionsFcn );
    hasLibFcnStub = any( isLibFcn );
else
    hasLibFcnStub = false;
    isLibFcn = false( size( undefinedFunctions ) );
end

if ~isempty( undefinedFunctions ) && self.hasSLCCCompliantInfo
    isSLCCCompliant = polyspace.internal.codeinsight.CodeInfo.isSLCCImportCompliant( undefinedFunctions, true );







    undefinedSLCCFunctions = undefinedFunctions( isSLCCCompliant & ~isLibFcn );
    undefinedGenericFunctions = undefinedFunctions( ~isSLCCCompliant | isLibFcn );
else
    undefinedSLCCFunctions = [  ];
    undefinedGenericFunctions = undefinedFunctions( ~isLibFcn );
end

stubInfo.functionStubObjs = arrayfun( @( x )polyspace.internal.codeinsight.stubInfo.SLCCFunctionStubInfo( x ), undefinedSLCCFunctions );
stubInfo.genericStubObjs = arrayfun( @( x )polyspace.internal.codeinsight.stubInfo.genericFunctionStubInfo( x ), undefinedGenericFunctions );

typeList = internal.cxxfe.ast.types.Type.empty(  );

if ~isempty( undefinedFunctions )

    fList = [ undefinedFunctions.Function ];
    fTypes = [ fList.Type ];
    for fIdx = 1:numel( fTypes )
        if ( fTypes( fIdx ).ParamTypes.Size > 0 )
            typeList = [ typeList, fTypes( fIdx ).RetType, fTypes( fIdx ).ParamTypes.toArray ];%#ok<AGROW>
        else
            typeList = [ typeList, fTypes( fIdx ).RetType ];%#ok<AGROW>
        end
    end
end

stubInfo.variablesStubObjs = [  ];
vInfoList = self.CodeInsightInfo.Variables.toArray;
undefinedVariables = vInfoList( [ vInfoList.IsDefined ] == false );
undefinedVariables = undefinedVariables( [ undefinedVariables.IsRead ] == true | [ undefinedVariables.IsWritten ] == true );
undefinedVariableList = [ undefinedVariables.Variable ];
if ~isempty( undefinedVariableList )
    typeList = [ typeList, [ undefinedVariableList.Type ] ];
end

[ ~, IA, ~ ] = unique( string( { typeList.UUID } ), 'stable' );
typeList = typeList( IA );


typeList = arrayfun( @( x )internal.cxxfe.ast.types.Type.skipQualifiers( x ), typeList, 'UniformOutput', false );
if ~isempty( typeList )
    typeList = [ typeList{ : } ];
    [ ~, IA, ~ ] = unique( string( { typeList.UUID } ), 'stable' );
    typeList = typeList( IA );
end







headerGraph = digraph;
stubInfo.TypeNoIncludes = string( [  ] );
originalHeaders = string( [  ] );
if options.AddOriginalIncludeList
    [ originalHeaders, headerGraph ] = self.getHeaderList(  );
end





[ typeIncludes, typeWithNoIncludes ] = polyspace.internal.codeinsight.CodeInfo.getTypeIncludes( typeList );
if ~isempty( typeWithNoIncludes )
    stubInfo.TypeNoIncludes = options.CodeInsightObj.getTypeDefinitions( typeWithNoIncludes );
end


if options.AddOriginalIncludeList
    stubInfo.TypeIncludes = polyspace.internal.codeinsight.CodeInfo.filterHeadersFromGraph( originalHeaders, typeIncludes, headerGraph );
else
    stubInfo.TypeIncludes = typeIncludes;
end

if ~isempty( stubInfo.functionStubObjs )

    exportedGlobals = arrayfun( @( x )"extern " + x, [ stubInfo.functionStubObjs.extraGlobal ] );





    exportedGlobalDefinitions = arrayfun( @( x )x, [ stubInfo.functionStubObjs.extraGlobalDefinitions ] );
else
    exportedGlobals = string( [  ] );
    exportedGlobalDefinitions = string( [  ] );
end
hTypeIncludes = "";
hexportedGlobalsDefs = "";

headerFileList = string( [  ] );

if ~isempty( stubInfo.TypeIncludes )
    headerFileList = "#include """ + stubInfo.TypeIncludes + """";
end

hVarDecls = "";
if ~isempty( undefinedVariables )
    varToDeclareList = undefinedVariables( [ undefinedVariables.IsDeclared ] == true );
    if ~isempty( varToDeclareList )
        varToDeclareVariableList = [ varToDeclareList.Variable ];

        varDeclList = arrayfun( @( x )( "extern " + polyspace.internal.codeinsight.CodeInfo.generateTypeName( x.Type, x.Name ) ), varToDeclareVariableList );

        if ( ~isempty( varDeclList ) )
            variableHeader =  ...
                "/*************************************************************************/" + newline +  ...
                "/* Global Variable declarations                                          */" + newline +  ...
                "/*************************************************************************/" + newline;
            hVarDecls = variableHeader + join( varDeclList, ";" + newline ) + ";" + newline;
        end
    end
end

if ~isempty( headerFileList )
    [ ~, IA, ~ ] = unique( headerFileList, 'stable' );
    headerFileList = headerFileList( IA );
    hTypeIncludes = hTypeIncludes + join( headerFileList, newline ) + newline;
end

hTypeNoIncludes = "";
if ~isempty( stubInfo.TypeNoIncludes )
    hTypeNoIncludes = "/*************************************************************************/" + newline +  ...
        "/* Generated Types for Stubbed Functions Interface                       */" + newline +  ...
        "/*************************************************************************/" + newline +  ...
        join( stubInfo.TypeNoIncludes, newline ) + newline +  ...
        newline;
end

if ~isempty( exportedGlobals )
    hexportedGlobalsDefs = "/*************************************************************************/" + newline +  ...
        "/* Generated Global Variables for Stubbed Functions Interface            */" + newline +  ...
        "/*************************************************************************/" + newline +  ...
        join( exportedGlobals, newline ) + newline +  ...
        newline;
end

headerContent = "";
sourceContent = "";
funDecls = "";

if ~isempty( stubInfo.functionStubObjs )

    decls = [ stubInfo.functionStubObjs.Signature ];
    funDecls = funDecls + newline +  ...
        "/*************************************************************************/" + newline +  ...
        "/* Function Declarations (SLCC Compliant)                                */" + newline +  ...
        "/*************************************************************************/" + newline +  ...
        sprintf( "%s;\n", decls ) +  ...
        newline;
end

if ~isempty( stubInfo.genericStubObjs )

    decls = [ stubInfo.genericStubObjs.Signature ];
    funDecls = funDecls + newline +  ...
        "/*************************************************************************/" + newline +  ...
        "/* Function Declarations (Generic)                                       */" + newline +  ...
        "/*************************************************************************/" + newline +  ...
        sprintf( "%s;\n", decls ) +  ...
        newline;
end

if ~strcmp( hTypeIncludes, "" ) || ~strcmp( hTypeNoIncludes, "" ) || ~strcmp( hexportedGlobalsDefs, "" ) || ~strcmp( funDecls, "" ) || ~strcmp( hVarDecls, "" )
    headerContent = hTypeIncludes + newline + hTypeNoIncludes + newline + hexportedGlobalsDefs + newline + hVarDecls + newline + funDecls + newline;
end




if ~isempty( stubInfo.functionStubObjs ) && ~hasLibFcnStub && any( [ stubInfo.functionStubObjs.useMemCpy ] )
    sourceContent = sourceContent + sprintf( '#include <string.h> /* memcpy */' ) + newline;
end



    function res = getNameForTypeToReport( aType )
        t = internal.cxxfe.ast.types.Type.skipTyperefs( aType );
        res = string( t.Name );
    end


varHasIncompleteType = arrayfun( @( x )( hasIncompleteType( x ) ), undefinedVariableList );
if any( varHasIncompleteType )

    ivList = undefinedVariableList( varHasIncompleteType );
    itList = [ ivList.Type ];
    itNameList = arrayfun( @( x )getNameForTypeToReport( x ), itList );
    warningState = warning( 'off', 'backtrace' );
    ls1 = length( ivList );
    [ name{ 1:ls1 } ] = deal( ivList.Name );
    tname = unique( itNameList );
    x = strjoin( name, ", " );
    y = strjoin( tname, ", " );

    self.MissingTypeDefinition = y;
    m = message( 'cxxfe:codeinsight:IncompleteTypeForVars', x, newline, y );
    warning( m );
    warning( warningState );
end
undefinedVariableList = undefinedVariableList( ~varHasIncompleteType );

if ~isempty( undefinedVariableList )

    isconstVar = arrayfun( @( x )( isconstvariable( x ) ), undefinedVariableList );
    varDefList = arrayfun( @( x )( generateTypeName( x.Type, x.Name, options.Metadata ) ), undefinedVariableList );

    if any( isconstVar )
        sourceContent = sourceContent + "/*************************************************************************/" + newline +  ...
            "/* Constant Global Variable definitions                                  */" + newline +  ...
            "/*************************************************************************/" + newline +  ...
            join( varDefList( isconstVar ), newline ) + newline +  ...
            newline;
    end
    if any( ~isconstVar )
        sourceContent = sourceContent + "/*************************************************************************/" + newline +  ...
            "/* Global Variable definitions                                           */" + newline +  ...
            "/*************************************************************************/" + newline +  ...
            join( varDefList( ~isconstVar ), newline ) + newline +  ...
            newline;
    end
end


if ~isempty( stubInfo.functionStubObjs )
    if ( ~isempty( exportedGlobalDefinitions ) )

        sourceContent = sourceContent + "/*************************************************************************/" + newline +  ...
            "/* Generated Global Variables for Stubbed Functions Interface            */" + newline +  ...
            "/*************************************************************************/" + newline +  ...
            join( exportedGlobalDefinitions, newline ) + newline +  ...
            newline;
    end

    sourceContent = sourceContent + "/*************************************************************************/" + newline +  ...
        "/* Function Definitions (SLCC compliant)                                 */" + newline +  ...
        "/*************************************************************************/" + newline +  ...
        join( arrayfun( @( x )x.getDefinition(  ), stubInfo.functionStubObjs ), newline ) +  ...
        newline;
end


if ~isempty( stubInfo.genericStubObjs )

    sourceContent = sourceContent + "/*************************************************************************/" + newline +  ...
        "/* Function Definitions (Generic)                                        */" + newline +  ...
        "/*************************************************************************/" + newline +  ...
        join( arrayfun( @( x )x.getDefinition(  ), stubInfo.genericStubObjs ), newline ) +  ...
        newline;
end
end

function res = hasIncompleteType( variable )
res = polyspace.internal.codeinsight.CodeInfo.isAliasToIncompleteType( variable.Type );
end

function result = isconstvariable( variable )
result = isconsttype( variable.Type );
end

function result = isconsttype( type )
if type.isQualifiedType
    result = type.IsConst;
else
    if type.isArrayType
        result = isconsttype( type.Type );
    else
        result = false;
    end
end
end

function result = generateTypeName( variableType, variableName, metadata )
result = polyspace.internal.codeinsight.CodeInfo.generateTypeName( variableType, variableName );

if ~isempty( metadata ) && ~metadata.isempty(  )
    extraInfoStruct = metadata.getVariableInfo( string( variableName ) );
    if ~isempty( extraInfoStruct )
        assignStr = '';
        realValStr = '';
        unitStr = '';
        descStr = '';

        if ~isempty( extraInfoStruct.Value.char )
            arrAssignParenL = "";
            arrAssignParenR = "";
            valArr = split( extraInfoStruct.Value.char );
            valArr = valArr( ~cellfun( 'isempty', valArr ) );
            if length( valArr ) > 1
                arrAssignParenL = "{ ";
                arrAssignParenR = " }";
            end
            valStr = join( valArr, ", " );
            assignStr = "  =  " + arrAssignParenL + valStr{ 1 } + arrAssignParenR;
        end
        if ~isempty( extraInfoStruct.RealValue.char )
            realValStr = "Real Value: [" + extraInfoStruct.RealValue.char + "] ";
        end
        if ~isempty( extraInfoStruct.Units.char )
            unitStr = "Unit: <" + extraInfoStruct.Units.char + "> ";
        end
        if ~isempty( extraInfoStruct.Description.char )
            descStr = [ 'Description: ', '"', extraInfoStruct.Description.char, '" ' ];
        end
        extraInfo = assignStr + ";";
        if ~isempty( realValStr ) || ~isempty( unitStr ) || ~isempty( descStr )
            extraInfo = extraInfo + " /* " + realValStr + unitStr + descStr + " */";
        end
        result = result + extraInfo;
        return ;
    end
else
    if variableType.isArrayType
        result = result + " = {0}";
    end
end
result = result + ";";
end

