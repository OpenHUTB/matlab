function[transf_mat,am,freq,asatout]=processp2d(h,simfreq)






    myref=getreference(h);
    myp2d=myref.P2DData;
    intptype=lower(h.IntpType);
    ls11=interp(myp2d,'ls11',intptype,simfreq);
    ls21=interp(myp2d,'ls21',intptype,simfreq);
    ls12=interp(myp2d,'ls12',intptype,simfreq);
    [ls22,freq,pin]=interp(myp2d,'ls22',intptype,simfreq);


    z0=h.Z0;zs=h.ZS;zl=h.ZL;
    transf_mat=zeros(length(pin),length(simfreq));
    for ii=1:length(pin)
        sparam=zeros(2,2,length(simfreq));
        sparam(1,1,:)=ls11(ii,:);
        sparam(2,1,:)=ls21(ii,:);
        sparam(1,2,:)=ls12(ii,:);
        sparam(2,2,:)=ls22(ii,:);
        transf_mat(ii,:)=s2tf(sparam,z0,zs,zl);
    end


    R0=real(z0);
    am=sqrt(R0*pin);

    pout_max=max(unique(cat(1,myp2d.P2{:})));
    asatout=sqrt(R0*pout_max);