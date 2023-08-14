function implInfo=truncateImplParams(~,slbh,implInfo)

    params={};
    if slbh<0
        return;
    end

    blockType=get_param(slbh,'BlockType');




    NFPSupportedBlks={...
    'MinMax',...
    };



    if~strcmp(blockType,NFPSupportedBlks)
        params=[params,{'latencystrategy'}];
    end


    if~isempty(params)
        implInfo.remove(params);
    end

    return
