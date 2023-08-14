function logSelectedBlocksOnlyCB(cbinfo,action)




    mdlHandle=simscape.internal.sl_toolstrip.getModelHandle(cbinfo);
    if(~isempty(mdlHandle))
        set_param(mdlHandle,'SimscapeLogType','local');
        action.selected=1;
    end
end