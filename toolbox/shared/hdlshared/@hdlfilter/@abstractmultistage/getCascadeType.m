function cascadeType=getCascadeType(this)






    nstages=length(this.Stage);
    rcf=this.RateChangeFactors;
    if size(rcf,1)~=nstages
        rcf=repmat(rcf,nstages,1);
    end

    if isfarrowcascade(this)
        interp=any(rcf(1:end-1,1)~=1);
    else
        interp=any(rcf(:,1)~=1);
    end

    if isfarrowcascade(this)
        decim=any(rcf(1:end-1,2)~=1);
    else
        decim=any(rcf(:,2)~=1);
    end
    if isfarrowcascade(this)
        singlerate=all(rcf(1:end-1,1)==1)&&all(rcf(1:end-1,2)==1);
    else
        singlerate=all(rcf(:,1)==1)&&all(rcf(:,2)==1);
    end

    if interp
        cascadeType='interpolating';
        if decim||singlerate
            error(message('HDLShared:hdlfilter:wrongrcf1'));

        end
    elseif decim
        cascadeType='decimating';
        if singlerate
            error(message('HDLShared:hdlfilter:wrongrcf2'));
        end
    elseif singlerate
        cascadeType='singlerate';
    else
        error(message('HDLShared:hdlfilter:wrongrcf3'));

    end


    function yesno=isfarrowcascade(this)

        yesno=isa(this.Stage(end),'hdlfilter.farrowsrc');



