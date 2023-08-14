function ret=hasTunableParam(blk)




    assert(strcmp(get_param(blk,'MaskType'),'Register Write'),...
    'Internal error: MaskType must be Register Write.');
    if strcmpi(get_param(blk,'OutputSink'),'Base workspace')||...
        strcmpi(get_param(blk,'OutputSink'),'IP core register')
        ret=true;
    else
        ret=false;
    end
end

