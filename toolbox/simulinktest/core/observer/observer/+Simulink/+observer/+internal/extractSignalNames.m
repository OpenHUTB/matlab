





function elems=extractSignalNames(signalString)
    splitElems=string(signalString).split('.');


    names=splitElems.extract(alphanumericsPattern+lookAheadBoundary("("|lineBoundary));

    indices=arrayfun(@extractIndex,splitElems,"UniformOutput",false);
    assert(length(names)==length(indices));

    elems=struct("name",names.cellstr,"index",indices);
end



function indexVec=extractIndex(elemStr)
    elemStr=elemStr.extractBetween("(",")");
    idxStr=elemStr.extract(digitsPattern);
    if isempty(idxStr)
        indexVec=-1;
    else
        indexVec=idxStr.double.';
    end
end
