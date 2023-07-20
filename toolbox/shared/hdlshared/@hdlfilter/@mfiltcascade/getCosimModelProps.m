function[ratechange,rtsettings,varname,varvalue]=getCosimModelProps(this)





    rcf=this.RateChangeFactors;

    if all(rcf(:)==1)

        ratechange=false;
        rtsettings={};
        varname='';
        varvalue=[];
    elseif all(rcf(:,1)>=rcf(:,2))

        ratechange=true;
        rtsettings={'DataIntegrity','off'};
        varname='InterpolationFactor';
        varvalue=prod(rcf(:,1));

    elseif all(rcf(:,1)<=rcf(:,2))

        ratechange=true;
        rtsettings={'OutPortSampleTimeOpt','Inherit'};
        varname='DecimationFactor';
        varvalue=prod(rcf(:,2));

    else
        error(message('HDLShared:hdlfilter:unsupportedMfiltCascade'));
    end
