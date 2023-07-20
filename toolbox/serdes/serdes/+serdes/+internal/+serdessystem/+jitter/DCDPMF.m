function pmf=DCDPMF(t,tDCD)



















    narginchk(2,2)
    nargoutchk(0,1)
    fcnName='DCDPMF';
    validateattributes(t,{'numeric'},{'vector','finite','real'},fcnName,'t',1);
    validateattributes(tDCD,{'numeric'},{'scalar','finite'},fcnName,'tDCD',2);

    pmf=zeros(size(t));
    if tDCD/2<=t(end)


        [~,ndx1]=min(abs(t-tDCD/2));
        [~,ndx2]=min(abs(t+tDCD/2));


        pmf([ndx1,ndx2])=1/2;
    else

        [~,ndx2]=min(abs(t));
        pmf(ndx2)=1;
    end
