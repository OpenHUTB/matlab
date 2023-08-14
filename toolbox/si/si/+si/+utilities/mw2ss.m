function ssName=mw2ss(mwName)






    switch string(mwName).lower
    case "parallellinkdesigner"
        ssName="qsi";
    case "seriallinkdesigner"
        ssName="qcd";
    otherwise
        ssName=mwName;
    end
end

