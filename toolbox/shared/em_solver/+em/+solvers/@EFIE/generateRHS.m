function generateRHS(obj)






    L=obj.Preconditioner{1};
    U=obj.Preconditioner{2};
    P=obj.Preconditioner{3};
    Q=obj.Preconditioner{4};
    D=obj.Preconditioner{5};
    if~isempty(Q)
        b=Q*(U\(L\(P*(D\obj.V_efie))));
    else
        b=(U\(L\(P*(obj.V_efie))));
    end



    obj.RHS=b;
end