function pmf=SjPMF(t,tSj)


















    narginchk(2,2)
    nargoutchk(0,1)
    fcnName='SjPMF';
    validateattributes(t,{'numeric'},{'vector','finite','real'},fcnName,'t',1);
    validateattributes(tSj,{'numeric'},{'scalar','finite'},fcnName,'tSj',2);


    pmf=real(1./(pi*sqrt(tSj^2-t.^2)));


    pmf(abs(t)==tSj)=0;


    vsum=sum(pmf);
    if vsum~=0
        pmf=pmf/vsum;
    end