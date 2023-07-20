function transf=transfunc(h)







    z0=get(h,'Z0');
    zs=get(h,'ZS');
    zl=get(h,'ZL');
    if(real(z0)==0&&imag(z0)==0)
        z0=eps;
    end
    if(real(zs)==0&&imag(zs)==0)
        zs=eps;
    end
    if(real(zl)==0&&imag(zl)==0)
        zl=eps;
    end

    sparams=h.S_Parameters;
    if isempty(sparams)
        transf=zl./(zs+zl);
    elseif all(sparams(1,1,:)==0)&&all(sparams(1,2,:)==1)&&...
        all(sparams(2,1,:)==1)&&all(sparams(2,2,:)==0)
        transf=zl./(zs+zl);
    elseif all(sparams(1,1,:)==sparams(1,1,1))&&...
        all(sparams(1,2,:)==sparams(1,2,1))&&...
        all(sparams(2,1,:)==sparams(2,1,1))&&...
        all(sparams(2,2,:)==sparams(2,2,1))
        transf=reshape(s2tf(sparams(:,:,1),z0,zs,zl,2),[1,1,1]);
    else
        transf=reshape(s2tf(sparams,z0,zs,zl,2),[1,1,length(h.Freq)]);
    end