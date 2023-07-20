function isMatch=matchObjTypes(allObjH,allIsSf,validBlockTypes,validSfIsas,isAnnotation)





    allIsModel=false(length(allObjH),1);
    isMatch=allIsModel;
    allIsModel(1)=true;

    slBlockTypes=rmisl.cellGetParam(allObjH(~allIsSf&~allIsModel&~isAnnotation),'BlockType');

    validIds=[];
    for validIsa=validSfIsas(:)'
        newIds=sf('find',allObjH(allIsSf),'.isa',validIsa);
        newIds=newIds(:);
        validIds=[validIds;newIds];%#ok<AGROW>
    end

    [~,~,slMatch]=rmiut.repsetmap(slBlockTypes,validBlockTypes);
    [sfMatch,~]=rmiut.findidx(validIds,allObjH(allIsSf));
    isMatch(~allIsSf&~allIsModel&~isAnnotation)=slMatch;
    isMatch(allIsSf)=sfMatch;
    isMatch(isAnnotation)=false;
end
