function enablePolariInitBannerMessage(ena)







    if nargin<1
        ena=true;
    end
    if~ena
        setappdata(0,'polarpatternSuppressInitBanner',ena);
    else
        ena=getappdata(0,'polarpatternSuppressInitBanner');
        if~isempty(ena)
            rmappdata(0,'polarpatternSuppressInitBanner');
        end
    end
