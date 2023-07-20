function tf=isAnalyzeAllChoicesEnabled(blk)







    if isGPCOnlyBlock(blk)
        tf=isGPCEnabled(blk);
        return;
    end
    if Simulink.variant.reducer.utils.isLabelMode(blk)








        tf=false;
        return;
    end
    tf=isAACEnabled(blk);
end

function tf=isGPCOnlyBlock(blk)


    isEventListener=isequal(get_param(blk,'BlockType'),'EventListener');


    isTriggerPort=isequal(get_param(blk,'BlockType'),'TriggerPort');


    tf=isEventListener||isTriggerPort;
end

function tf=isGPCEnabled(blk)
    GPC=get_param(blk,'GeneratePreprocessorConditionals');
    tf=isequal(GPC,'on');
end

function tf=isAACEnabled(blk)
    VAT=get_param(blk,'VariantActivationTime');



    isUD=isequal(VAT,'update diagram');
    tf=~isUD;
end


