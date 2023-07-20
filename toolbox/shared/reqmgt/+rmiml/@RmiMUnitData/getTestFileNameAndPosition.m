function[testFileName,startPosition,endPosition]=getTestFileNameAndPosition(parseTree)


















    testFileName="";
    [startPosition,endPosition]=deal(-1);

    if parseTree.root.FileType==mtree.Type.ClassDefinitionFile
        [testFileName,startPosition,endPosition]=getClassDefNameAndLocation(parseTree);
    elseif parseTree.root.FileType==mtree.Type.FunctionFile
        [testFileName,startPosition,endPosition]=getTopFunctionNameAndLocation(parseTree);
    end
end

function[testFileName,startPosition,endPosition]=getClassDefNameAndLocation(parseTree)
    [startPosition,endPosition]=deal(-1);
    classDefNode=parseTree.mtfind('Kind','CLASSDEF');
    if~isempty(classDefNode)
        testFileName=classDefNode.Cexpr.Left.string;
        startPosition=classDefNode.leftposition;
        endPosition=classDefNode.Cexpr.Left.rightposition+1;
    end
end

function[testFileName,startPosition,endPosition]=getTopFunctionNameAndLocation(parseTree)
    [startPosition,endPosition]=deal(-1);
    allFunctionBlocks=parseTree.mtfind('Kind','FUNCTION');
    if~isempty(allFunctionBlocks)
        topFunctionBlock=allFunctionBlocks.first;
        testFileName=topFunctionBlock.Fname.string;
        startPosition=topFunctionBlock.leftposition;
        endPosition=topFunctionBlock.rightposition+1;
    end
end
