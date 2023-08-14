function flag=checkCyclic_private(mat,dim,tol)%#codegen




    coder.allowpcode('plain');


    maxDiff=tol*max(abs(mat(:)));


    mat2=shiftdim(mat,dim-1);


    first=mat2(1,:);
    last=mat2(end,:);
    if all(abs(first-last)<=maxDiff)
        flag=true;
    else
        flag=false;
    end

end