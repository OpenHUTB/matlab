function value=pct(value)






    persistent pctAvailable;
    if isempty(pctAvailable)
        pctAvailable=false;
        mlock;
    end

    if(strcmp(value,'on')==1)&&~pctAvailable
        pctAvailable=true;
    elseif(strcmp(value,'off')==1)&&pctAvailable
        pctAvailable=false;
    else
        if pctAvailable&&matlab.internal.parallel.isPCTLicensed()
            value='on';
        else
            value='off';
        end
    end
end