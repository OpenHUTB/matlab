function[thred,step,stmetNT]=renormparam(~,trellis,nsDec)








    n=log2(trellis.numOutputSymbols);
    BMmax=realmax(fi(0,0,n+nsDec-1,0));
    Decmax=realmax(fi(0,0,nsDec,0));
    cdist=distspec(trellis);

    uplimit=BMmax.data+Decmax.data*cdist.dfree;
    nsST=ceil(log2(uplimit));
    if nsDec<7
        stmetNT=numerictype(0,nsST+1,0);
    else
        stmetNT=numerictype(0,nsST+3,0);
    end


    SMmax=realmax(fi(0,stmetNT));


    thred=0.25*(SMmax.data+1);
    numstate=trellis.numStates;

    step=floor(thred/(log2(numstate)+3));



    if(step==0)
        step=1;
        thred=step*(log2(numstate)+3);
        uplimit=thred+n*Decmax.data*thred;
        nsST=ceil(log2(uplimit));
        stmetNT=numerictype(0,nsST,0);
    end
