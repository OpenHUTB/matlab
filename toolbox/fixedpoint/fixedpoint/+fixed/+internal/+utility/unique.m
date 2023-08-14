function B=unique(A,compare)
























    narginchk(2,2);
    validateattributes(compare,{'function_handle'},{'scalar'},2);
    assert(nargin(compare)==2,...
    message("fixed:utility:expectedFcnWithNInputs",2));


    B=splitAndMerge(A(:),compare);

    if isrow(A)
        B=B';
    end
end

function B=splitAndMerge(A,compare)


    n=numel(A);
    if n>1
        m=floor(n/2);
        Al=splitAndMerge(A(1:m),compare);
        Ar=splitAndMerge(A(m+1:end),compare);
        B=uniqueMerge(Al,Ar,compare);
    else
        B=A;
    end
end

function B=uniqueMerge(Al,Ar,compare)


    nl=numel(Al);
    nr=numel(Ar);
    B=[Al;Ar];
    i=1;
    j=1;
    szB=0;
    for k=1:numel(B)
        if i<=nl&&(j>nr||compare(Al(i),Ar(j)))
            szB=szB+1;
            B(szB)=Al(i);
            i=i+1;
        else
            if i>nl||compare(Ar(j),Al(i))
                szB=szB+1;
                B(szB)=Ar(j);
            end
            j=j+1;
        end
    end
    B=B(1:szB);
end
