function mwName=ss2mw(ssName)






    switch string(ssName).lower
    case "qsi"
        mwName="parallelLinkDesigner";
    case "qcd"
        mwName="serialLinkDesigner";
    otherwise
        mwName=ssName;
    end
end

