function out=appcoef(c,l,Lo_R,Hi_R,rmax,nmax,n)%#codegen




    coder.allowpcode('plain');


    coder.gpu.internal.kernelfunImpl(false);


    acol=coder.nullcopy(zeros(l(1),1,'like',c));
    for k=1:l(1)
        acol(k)=c(k);
    end


    cell_a=coder.nullcopy(cell(1,(nmax+1)));
    cell_a{nmax+1}=acol;

    imax=rmax+1;
    for p=nmax:-1:n+1
        d=detcoef(c(:),l(:),p);
        cell_a{p}=idwt(cell_a{p+1},d(:),Lo_R,Hi_R,l(imax-p));
    end
    out=cell_a{n+1};

end