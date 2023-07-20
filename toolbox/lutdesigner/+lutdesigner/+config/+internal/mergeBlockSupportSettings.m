function bss=mergeBlockSupportSettings(bss1,bss2)




    import lutdesigner.lutfinder.Config

    m=containers.Map;


    for i=1:numel(bss1)
        m(getKey(bss1(i)))=bss1(i);
    end


    for i=1:numel(bss2)
        key=getKey(bss2(i));
        if~m.isKey(key)
            m(key)=bss2(i);
        end
    end


    if m.length>0
        bss=cellfun(@(key)Config.fromSetting(m(key)).toSetting(),m.keys)';
    else
        bss=lutdesigner.config.internal.createBlockSupportSetting([0,1]);
    end
end

function key=getKey(bss)
    key=sprintf('%s:%s',bss.BlockType,bss.MaskType);
end
