function [ testNames, startPositions, endPositions ] = getTestNamesAndPositions( parseTree, fullBodyPositions )

arguments
    parseTree
    fullBodyPositions = true;
end


testNames = {  };
[ startPositions, endPositions ] = deal(  - 1 );

if parseTree.root.FileType == mtree.Type.ClassDefinitionFile
    [ testNames, startPositions, endPositions ] = getFunctionDetailsForClassFile( parseTree, fullBodyPositions );
elseif parseTree.root.FileType == mtree.Type.FunctionFile
    [ testNames, startPositions, endPositions ] = getFunctionDetailsForFunctionFile( parseTree, fullBodyPositions );
end
end

function [ testNames, startPositions, endPositions ] = getFunctionDetailsForClassFile( parseTree, fullBodyPositions )
testMethodsTree = parseTree.mtfind( 'Kind', 'METHODS', 'Attr.Arg.List.Any.Left.String', 'Test' );
functionsFromTestMethodBlocks = testMethodsTree.Body.List.mtfind( 'Kind', 'FUNCTION' );

allFunctionNames = functionsFromTestMethodBlocks.Fname;
testNames = strings( allFunctionNames );

if fullBodyPositions
    startPositions = functionsFromTestMethodBlocks.lefttreepos.';
    endPositions = functionsFromTestMethodBlocks.righttreepos.' + 1;
else
    startPositions = allFunctionNames.lefttreepos.';
    endPositions = allFunctionNames.righttreepos.' + 1;
end
end

function [ testNames, startPositions, endPositions ] = getFunctionDetailsForFunctionFile( parseTree, fullBodyPositions )
allFunctionBlocks = parseTree.mtfind( 'Kind', 'FUNCTION' );
allFunctionNames = allFunctionBlocks.Fname;
allFunctionNameStrings = strings( allFunctionNames );

if fullBodyPositions
    allFunctionStartIndices = allFunctionBlocks.lefttreepos.';
    allFunctionEndIndices = allFunctionBlocks.righttreepos.' + 1;
else
    allFunctionStartIndices = allFunctionNames.lefttreepos.';
    allFunctionEndIndices = allFunctionNames.righttreepos.' + 1;
end

testFunctionFilter = startsWith( allFunctionNameStrings, "test", 'IgnoreCase', true ) | endsWith( allFunctionNameStrings, "test", 'IgnoreCase', true );
testFunctionFilter( 1 ) = false;

testNames = allFunctionNameStrings( testFunctionFilter );
startPositions = allFunctionStartIndices( testFunctionFilter );
endPositions = allFunctionEndIndices( testFunctionFilter );
end
