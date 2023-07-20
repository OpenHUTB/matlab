function block=promote_block(nl,block)

    block=get_param(block,'Handle');
    if(strcmp(get_param(block,'MaskType'),...
        'InnerPowersysBlock'))
        block=get_param(get_param(block,'Parent'),'Handle');
    end




