function UpdateSimscapeBlocksHelper(h)






    if h.CheckFlags.BlockReplace
        ReplaceInfo=getReplaceInfo();
        replaceBlocks(h,ReplaceInfo);
    end

end

function ReplaceInfo=getReplaceInfo

    ReplaceInfo={...
    {'MaskType','AC Voltage Source'},@callSimscapeBlockUpgradeFunction,'UpdateACSource';...
    {'MaskType','AC Current Source'},@callSimscapeBlockUpgradeFunction,'UpdateACSource';...
    };

    ReplaceInfo=cell2struct(ReplaceInfo,{'BlockDesc','ReplaceFcn','data'},2);

end


