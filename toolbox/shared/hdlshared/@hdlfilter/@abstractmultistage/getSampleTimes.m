function sampletimes=getSampleTimes(this)





    nstages=length(this.Stage);
    sampletimes=ones(1,nstages+1);
    isinterp=this.isInterpolating;
    rcf=this.RateChangeFactors;

    castype=getCascadeType(this);
    switch castype
    case 'interpolating'
        rcf=rcf(:,1)';
        rcf=normalize(rcf);
        maxrate=max(rcf);
        rcf=maxrate*ones(1,length(rcf))./rcf;
        sampletimes=[maxrate,rcf];
    case 'decimating'
        rcf=rcf(:,2)';
        rcf=normalize(rcf);
        sampletimes=[1,rcf];
    case 'singlerate'
        sampletimes=ones(1,nstages+1);
    otherwise
        error(message('HDLShared:hdlfilter:wrongrcf'));
    end


    function new_rcf=normalize(rcf)


        new_rcf=rcf;
        for n=2:length(rcf)
            new_rcf(n:end)=new_rcf(n:end)*rcf(n-1);
        end


