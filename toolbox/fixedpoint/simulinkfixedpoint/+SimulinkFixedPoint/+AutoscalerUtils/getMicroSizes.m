function wordSizes=getMicroSizes(model)



    cs=getActiveConfigSet(model);
    wordSizes.char=get_param(cs,'ProdBitPerChar');
    wordSizes.short=get_param(cs,'ProdBitPerShort');
    wordSizes.int=get_param(cs,'ProdBitPerInt');
    wordSizes.long=get_param(cs,'ProdBitPerLong');
    wordSizes.longlong=get_param(cs,'ProdBitPerLongLong');
    wordSizes.longlongmode=int32(strcmp(get_param(cs,'ProdLongLongMode'),'on'));
end