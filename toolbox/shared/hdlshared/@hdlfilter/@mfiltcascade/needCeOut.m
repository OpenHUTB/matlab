function status=needCeOut(this)











    rcf=this.RateChangeFactors;
    if all(rcf(:,1)>=rcf(:,2))
        if~any(rcf(end,:)==1)
            status=false;
        elseif strcmpi(this.Implementation,'localmultirate')
            status=false;
        else
            status=true;
        end
    elseif all(rcf(:,1)<=rcf(:,2))
        status=false;
    else
        error(message('HDLShared:hdlfilter:unsupportedMfiltCascade'));
    end


