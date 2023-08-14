function tunableParamName=getTunableParamName(blk)





    assert(strcmp(get_param(blk,'MaskType'),'Register Write'),...
    'Internal error: MaskType must be Register Write.');
    if strcmpi(get_param(blk,'OutputSink'),'Base workspace')
        tunableParamName=get_param(blk,'TunableParamName');
    elseif strcmpi(get_param(blk,'OutputSink'),'IP core register')
        tunableParamName=get_param(blk,'RegisterName');
    else
        tunableParamName='';
    end
end

