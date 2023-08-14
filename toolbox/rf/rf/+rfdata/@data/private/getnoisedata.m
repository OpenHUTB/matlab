function[fmin,gammaopt,rn]=getnoisedata(h,noiseparams,format,z0)




    if isempty(noiseparams)
        fmin=[];
        gammaopt=[];
        rn=[];
        return
    end
    fmin=noiseparams(:,1);
    switch upper(format)
    case 'MA'
        R=noiseparams(:,2);
        theta=noiseparams(:,3)*pi/180;
        gammaopt=R.*exp(i*theta);
    case 'DB'
        R=10.^(noiseparams(:,2)/20);
        theta=noiseparams(:,3)*pi/180;
        gammaopt=R.*exp(i*theta);
    case 'RI'
        gammaopt=noiseparams(:,2)+i*noiseparams(:,3);
    end
    rn=z0*noiseparams(:,4);