function enableATGs(JTAGMaster,atg)
    for thisATG=1:numel(atg)
        JTAGMaster.writememory(atg(thisATG).enable,uint32(1));
    end
end

