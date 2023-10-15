function hasChanged = undefVariableDefinition( cInfo, fileToModify )

arguments
    cInfo( 1, 1 )polyspace.internal.codeinsight.CodeInfo
    fileToModify( 1, 1 )string
end

hasChanged = false;
vInfoList = cInfo.CodeInsightInfo.Variables.toArray;
if isempty( vInfoList )

    return ;
end


vInfoList = vInfoList( [ vInfoList.IsDefinedInHeader ] );
filecontent = split( string( fileread( fileToModify ) ), newline );
undefVarDecl = string( [  ] );

for vInfo = vInfoList







    defPos = vInfo.Variable.DefPos;
    currFile = defPos.File.Path;
    if ~strcmp( fileToModify, currFile )
        continue ;
    end
    undefVarDecl( end  + 1 ) = vInfo.Variable.Name;%#ok<AGROW>

    startL = defPos.Line;
    startLine = filecontent( startL );
    filecontent( startL ) = "/* undefined variable */" + newline + "extern " + startLine;
    if ~hasChanged
        warningState = warning( 'off', 'backtrace' );
        m = message( 'cxxfe:codeinsight:FoundVariableDefinitionInFile', currFile );
        warning( m );
        warning( warningState );
    end
    hasChanged = true;
end


if hasChanged
    fid = fopen( fileToModify, 'w' );
    newfilecontent = filecontent.join( newline );
    fprintf( fid, "%s", newfilecontent );
    fclose( fid );
    warningState = warning( 'off', 'backtrace' );
    undefVarDecl = sort( undefVarDecl );
    m = message( 'cxxfe:codeinsight:UndefVariables', undefVarDecl.join( ", " ) );
    warning( m );
    warning( warningState );
end
end


