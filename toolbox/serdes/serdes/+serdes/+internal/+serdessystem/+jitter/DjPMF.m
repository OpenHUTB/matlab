function pmf=DjPMF(t,tDj)













    narginchk(2,2)
    nargoutchk(0,1)
    fcnName='DjPMF';
    validateattributes(t,{'numeric'},{'vector','finite','real'},fcnName,'t',1);
    validateattributes(tDj,{'numeric'},{'scalar','finite'},fcnName,'tDj',2);


    pmf=double(abs(t)<tDj);
    vsum=sum(pmf);
    if vsum~=0
        pmf=pmf/vsum;
    end