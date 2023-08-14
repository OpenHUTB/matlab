function[B,I]=sort(A,compare)


























    narginchk(2,2);
    validateattributes(compare,{'function_handle'},{'scalar'},2);
    assert(nargin(compare)==2,...
    message("fixed:utility:expectedFcnWithNInputs",2));
    if isempty(A)||isscalar(A)
        B=A;
        I=ones(size(A));
        return;
    end
    validateattributes(true(size(A)),{'logical'},{'vector'},1);


    B=A;
    n=numel(B);
    I=reshape(1:n,size(B));
    [B,I]=splitAndMerge(B,I,1,n,compare);
end

function[A,I]=splitAndMerge(A,I,l,r,compare)

    if r>l
        m=floor((l+r)/2);
        [A,I]=splitAndMerge(A,I,l,m,compare);
        [A,I]=splitAndMerge(A,I,m+1,r,compare);
        [A,I]=sortMerge(A,I,l,m,r,compare);
    end
end

function[A,I]=sortMerge(A,I,l,m,r,compare)

    Alocal=A(l:r);
    Ilocal=I(l:r);
    mlocal=m+1-l;
    rlocal=r+1-l;
    i=1;
    j=mlocal+1;
    for k=l:r
        if i<=mlocal&&(j>rlocal||compare(Alocal(i),Alocal(j)))
            A(k)=Alocal(i);
            I(k)=Ilocal(i);
            i=i+1;
        else
            A(k)=Alocal(j);
            I(k)=Ilocal(j);
            j=j+1;
        end
    end
end
