function lhs=generateLHS(obj,I)




    generateLHSEfie(obj,I);





    L=obj.Preconditioner{1};
    U=obj.Preconditioner{2};
    P=obj.Preconditioner{3};
    Q=obj.Preconditioner{4};
    D=obj.Preconditioner{5};
    if~isempty(Q)
        lhs=Q*(U\(L\(P*(D\obj.LHSEfie))));
    else
        lhs=(U\(L\(P*(obj.LHSEfie))));
    end




end

