function configureOptionalOutport(Block,OutportOptionParameter,OutportOptions)
    outportEnabled=get_param(Block,OutportOptionParameter);

    if strcmp(outportEnabled,'off')
        autoblksreplaceblock(Block,OutportOptions,1);
    else
        autoblksreplaceblock(Block,OutportOptions,2);
    end
end