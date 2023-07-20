function[validOrder,evalOrder,circularDependencyGroups]=determineEvalOrderFromDependencies(dependencyMatrix)

















    n=size(dependencyMatrix,1);







    dependencyMatrix=dependencyMatrix^(n-1);
    dependencyMatrix=spones(dependencyMatrix);





































    [p,q,~,~,cc,rr]=dmperm(dependencyMatrix);

    assert(all(rr(1:2)==1)&&all(rr(3:end)==n+1)&&all(cc(1:3)==1)&&all(cc(4:5)==n+1),...
    message('SimBiology:Internal:InternalError'));
    circularPortion=tril(dependencyMatrix(p,q),-1);
    validOrder=~nnz(circularPortion);
    evalOrder=p(end:-1:1);
    if validOrder
        circularDependencyGroups={};
    else


        [permutedCircularObjIndex,~]=find(circularPortion);
        circularDependencyIdx=p(unique(permutedCircularObjIndex));
        bins=conncomp(digraph(dependencyMatrix));
        cyclesIdx=unique(bins(circularDependencyIdx));
        numCycles=numel(cyclesIdx);
        circularDependencyGroups=cell(1,numCycles);
        for i=1:numCycles
            circularDependencyGroups{i}=find(bins==cyclesIdx(i));
        end
    end