function out=appcoef2(c,s,Lo_R,Hi_R,rmax,nmax,n)%#codegen




    coder.allowpcode('plain');


    coder.gpu.internal.kernelfunImpl(false);


    if length(s(1,:))<3
        dimFactor=1;
    else
        dimFactor=3;
    end


    a=coder.nullcopy(zeros(s(1,1),s(1,2),dimFactor,'like',c));

    for i=1:s(1,1)*s(1,2)*dimFactor
        a(i)=c(i);
    end

    cell_a=coder.nullcopy(cell(1,(nmax+1)));
    cell_a{nmax+1}=a;

    rm=rmax+1;
    for p=nmax:-1:n+1
        [h,v,d]=detcoef2('all',c,s,p);
        cell_a{p}=idwt2(cell_a{p+1},h,v,d,Lo_R,Hi_R,s(rm-p,:));
    end
    out=cell_a{n+1};

end