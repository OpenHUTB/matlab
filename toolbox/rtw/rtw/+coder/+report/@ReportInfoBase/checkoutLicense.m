function checkoutLicense(obj)
    lics=obj.getLicenseRequirements();
    for i=1:length(lics)
        [lic,~]=builtin('license','checkout',lics{i});
        if~lic
            DAStudio.error('CoderFoundation:report:ReportMissingLicense',lics{i});
        end
    end
end
