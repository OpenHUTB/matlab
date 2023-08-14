function[matchingSlsfObj,hasCandidates]=findMatchingPossibleRoot(topRootId,blockNameToFind,checksumToFind)








    matchingSlsfObj=[];
    hasCandidates=false;

    ownerTopSlsf=cv('get',topRootId,'.topSlsf');


    allIds=[ownerTopSlsf,cv('DecendentsOf',ownerTopSlsf)];

    possibleRoots=cv('find',allIds,'.name',blockNameToFind);

    if isempty(possibleRoots)
        return;
    end

    hasCandidates=true;



    for idx=1:numel(possibleRoots)
        curPossibleRoot=possibleRoots(idx);
        if isequal(checksumToFind,cv('get',curPossibleRoot,'.cvChecksum'))
            matchingSlsfObj=curPossibleRoot;
            return;
        end
    end
end
