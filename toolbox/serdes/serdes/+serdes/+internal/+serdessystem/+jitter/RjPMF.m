function pmf=RjPMF(t,tRj)


















    narginchk(2,2)
    nargoutchk(0,1)
    fcnName='RjPMF';
    validateattributes(t,{'numeric'},{'vector','finite','real'},fcnName,'t',1);
    validateattributes(tRj,{'numeric'},{'scalar','finite'},fcnName,'tRj',2);


    pmf=exp(-t.^2/(2*tRj^2))/(tRj*sqrt(2*pi));
    vsum=sum(pmf);
    if vsum~=0
        pmf=pmf/vsum;
    end
