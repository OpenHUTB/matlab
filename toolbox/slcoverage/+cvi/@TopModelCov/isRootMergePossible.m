
function canHarnessMapBackToOwner=isRootMergePossible(modelcovId,currentRootId)





    if nargin<2
        currentRootId=cv('get',modelcovId,'.activeRoot');
    end
    canHarnessMapBackToOwner=cv('get',modelcovId,'.canHarnessMapBackToOwner');


    if cv('get',modelcovId,'.simMode')~=SlCov.CovMode.Normal
        return;
    end


    ownerModel=cv('get',modelcovId,'.ownerModel');
    ownerBlock=cv('get',modelcovId,'.ownerBlock');
    if isempty(ownerModel)||isempty(ownerBlock)||...
        ~canHarnessMapBackToOwner

        return;
    end
    dbVersion=cv('get',modelcovId,'.dbVersion');
    ownerModelMangledName=SlCov.CoverageAPI.mangleModelcovName(ownerModel,SlCov.CovMode.Normal,dbVersion);
    ownerModelcovId=SlCov.CoverageAPI.findModelcovMangled(ownerModelMangledName);
    if isempty(ownerModelcovId)

        return;
    end

    ownerTopRoot=cv('get',ownerModelcovId,'.rootTree.child');
    if(ownerTopRoot==0)||isempty(ownerTopRoot)

        return;
    end


    currentTopSlsf=cv('get',currentRootId,'.topSlsf');
    blockNameToFind=cv('get',currentTopSlsf,'.name');
    checksumToFind=cv('get',currentTopSlsf,'.cvChecksum');
    [matchingSlsfObj,hasCandidates]=cvi.TopModelCov.findMatchingPossibleRoot(...
    ownerTopRoot,blockNameToFind,checksumToFind);

    if~hasCandidates

        ownerTopSlsf=cv('get',ownerTopRoot,'.topSlsf');
        blockNameToFind=cv('get',ownerTopSlsf,'.name');
        checksumToFind=cv('get',ownerTopSlsf,'.cvChecksum');
        [matchingSlsfObj,hasCandidates]=cvi.TopModelCov.findMatchingPossibleRoot(...
        currentRootId,blockNameToFind,checksumToFind);
    end

    if hasCandidates
        canHarnessMapBackToOwner=~isempty(matchingSlsfObj);
    end
end
