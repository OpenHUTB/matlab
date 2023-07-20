function out=checkLicense(obj)
    out=true;
    rptLicense=obj.getLicenseRequirement();
    if~iscell(rptLicense)
        rptLicense={rptLicense};
    end
    for i=1:length(rptLicense)
        [out,~]=builtin('license','checkout',rptLicense{i});
        if~out
            return
        end
    end
end
