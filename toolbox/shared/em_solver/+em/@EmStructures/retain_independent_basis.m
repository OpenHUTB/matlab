function metalbasis=retain_independent_basis(t,metalbasis)




    EdgesTotal=length(metalbasis.Edges);
    Edge_flipped=[metalbasis.Edges(2,:);metalbasis.Edges(1,:)];
    Remove=[];
    for m=1:EdgesTotal
        Edge_m=repmat(metalbasis.Edges(:,m),[1,EdgesTotal]);
        Ind1=any(metalbasis.Edges-Edge_m);
        Ind2=any(Edge_flipped-Edge_m);
        A=find(Ind1.*Ind2==0);
        if(length(A)==3)
            Out=find(t(4,metalbasis.TrianglePlus(A)+1)==...
            t(4,metalbasis.TriangleMinus(A)+1));
            Remove=[Remove,A(Out)];%#ok<*FNDSB,AGROW>
        end
    end


    metalbasis.Edges(:,Remove)=[];
    metalbasis.TrianglePlus(Remove)=[];
    metalbasis.TriangleMinus(Remove)=[];
    metalbasis.VerP(Remove)=[];
    metalbasis.VerM(Remove)=[];

end