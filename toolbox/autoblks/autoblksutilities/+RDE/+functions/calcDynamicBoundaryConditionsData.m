function[va95,rpa,vAvg]=calcDynamicBoundaryConditionsData(v,opMode,params)




    a=[nan;(v(3:end)-v(1:end-2))/2;nan];
    d=v*params.dt;
    va=v.*a;


    [G,GID]=findgroups(opMode);
    vAvg=zeros(size(GID));
    va95=zeros(size(GID));
    rpa=zeros(size(GID));
    for k=1:numel(GID)
        sel=(G==k);
        a_k=a(sel);
        d_k=d(sel);
        va_k=va(sel);
        v_k=v(sel);

        vAvg(k)=mean(v_k);
        posAcc=a_k>0.1;
        va95(k)=prctile(va_k(posAcc),95);
        rpa(k)=params.dt*sum(va_k(posAcc))/sum(d_k);
    end
end