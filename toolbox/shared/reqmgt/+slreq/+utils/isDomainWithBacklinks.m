function tf=isDomainWithBacklinks(domainLabel)







    if slreq.utils.isNativeDomain(domainLabel)



        tf=false;
    else
        destType=rmi.linktype_mgr('resolveByRegName',domainLabel);
        if isempty(destType)
            tf=false;
        else
            tf=~isempty(destType.BacklinkCheckFcn);
        end
    end
end
