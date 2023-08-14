function success=isInterpolating(this)






    nstages=length(this.Stage);
    rcf=this.RateChangeFactors;
    if size(rcf,1)~=nstages
        rcf=repmat(rcf,nstages,1);
    end

    if isfarrowcascade(this)
        success=any(rcf(1:end-1,1)~=1);
    else
        success=any(rcf(:,1)~=1);
    end


    function yesno=isfarrowcascade(this)

        yesno=isa(this.Stage(end),'hdlfilter.farrowsrc');

