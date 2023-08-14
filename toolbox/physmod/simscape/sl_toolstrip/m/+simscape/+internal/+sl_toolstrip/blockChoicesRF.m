function blockChoicesRF(cbinfo,action)




    blkHandle=simscape.internal.sl_toolstrip.getSelectedBlock(cbinfo);
    if isempty(blkHandle)
        action.enabled=false;
        return;
    end
    action.enabled=true;

    action.enabled=false;






    if(isempty(blkHandle))...
        ||(~simscape.engine.sli.internal.issimscapeblock(blkHandle))...
        ||(isempty(get_param(blkHandle,'SourceFile')))
        return
    end


    v=simscape.internal.variantsAndNames(blkHandle);
    if(numel(v)<2)
        action.enabled=false;
    else
        action.enabled=true;
    end
end

