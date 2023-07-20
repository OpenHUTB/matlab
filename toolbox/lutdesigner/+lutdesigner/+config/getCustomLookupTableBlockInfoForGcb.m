function info=getCustomLookupTableBlockInfoForGcb()


    block=get_param(gcb,'Handle');
    info=lutdesigner.config.getCustomLookupTableBlockInfo(block);
end
