function status=isTbSingleRate(this)







    rcf=this.RateChangeFactors;

    if all(rcf(:,1)>=rcf(:,2))
        status=false;
    elseif all(rcf(:,1)<=rcf(:,2))
        status=true;
    else
        error(message('HDLShared:hdlfilter:unsupportedMfiltCascade'));
    end


