function hasChanged = undefASM( cInfo, fileToModify, isCopied )








arguments
    cInfo( 1, 1 )polyspace.internal.codeinsight.CodeInfo
    fileToModify( 1, 1 )string
    isCopied( 1, 1 )logical = false
end

hasChanged = false;
fInfoList = cInfo.CodeInsightInfo.Functions.toArray;
if isempty( fInfoList )

    return ;
end


fInfoList = fInfoList( [ fInfoList.HasASMBlock ] );
filecontent = split( string( fileread( fileToModify ) ), newline );

for fInfo = fInfoList

    defRange = fInfo.DefinitionSourceRange;
    currFile = defRange.Start.File.Path;
    if ~strcmp( fileToModify, currFile )
        if isCopied
            [ ~, currFileName, currExt ] = fileparts( string( currFile ) );
            [ ~, copiedFileName, copiedExt ] = fileparts( string( fileToModify ) );
            if ~strcmp( copiedFileName + currExt, currFileName + copiedExt )
                continue ;
            end
        else
            continue ;
        end
    end


    startL = defRange.Start.Line;
    startCol = defRange.Start.Col;
    startLine = filecontent( startL );
    preStart = startLine.extractBefore( startCol );
    postStart = startLine.extractAfter( startCol - 1 );


    declPos = fInfo.Function.DeclPos.toArray;

    declToConsider = arrayfun( @( x )( ~isempty( x.File ) && strcmp( fileToModify, x.File.Path ) && x.Line ~= startL ), declPos );
    declPos = declPos( declToConsider );



    fStubInfo = polyspace.internal.codeinsight.stubInfo.genericFunctionStubInfo( fInfo );
    replacementText = "/* Function has been undefined because it contains assembly code */" + newline;
    if isempty( declPos )

        replacementText = replacementText + fStubInfo.Signature + ";";
    else
        if fInfo.Function.StorageClass == internal.cxxfe.ast.StorageClassKind.Static && fInfo.IsDeclared

            staticDeclPos = fInfo.Function.DeclPos.toArray;

            declToConsider = arrayfun( @( x )( ~isempty( x.File ) && strcmp( fileToModify, x.File.Path ) ), staticDeclPos );
            staticDeclPos = staticDeclPos( declToConsider );
            if ~isempty( staticDeclPos )
                lineToModify = unique( [ staticDeclPos.Line ] );

                for declLine = lineToModify

                    if startL ~= declLine
                        staticReplacementTxt = "/* static keyword has been removed because function has been undefined */" + newline + "/*static*/ ";
                        declLineTxt = filecontent( declLine );
                        filecontent( declLine ) = declLineTxt.replace( "static ", staticReplacementTxt );
                    end
                end
            end
        end
    end





    postStart = processComments( postStart );
    filecontent( startL ) = preStart + newline + replacementText + newline + "/****** ORIGINAL DEFINITION ********" + newline + postStart;


    endL = defRange.End.Line;
    endCol = defRange.End.Col;
    endLine = filecontent( endL );
    preEnd = endLine.extractBefore( endCol + 1 );

    preEnd = processComments( preEnd );
    postEnd = endLine.extractAfter( endCol );


    for blockL = startL + 1:endL - 1
        filecontent( blockL ) = processComments( filecontent( blockL ) );
    end


    filecontent( endL ) = preEnd + newline + "******* END OF ORIGNAL DEFINITION *********/" + newline + postEnd;
    warningState = warning( 'off', 'backtrace' );
    m = message( 'cxxfe:codeinsight:UndefASMFunction', currFile, newline, fInfo.Function.Name );
    warning( m );
    warning( warningState );
end


if ~isempty( fInfoList )
    hasChanged = true;
    fid = fopen( fileToModify, 'w' );
    fprintf( fid, "%s", filecontent.join( newline ) );
    fclose( fid );
end
end



function res = processComments( aLine )
arguments
    aLine( 1, 1 )string
end
res = aLine.replace( "*/", "*//*" );
end
