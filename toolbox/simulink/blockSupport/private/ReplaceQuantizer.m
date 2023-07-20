function ReplaceQuantizer(block,h)





    if askToReplace(h,block)

        entries=GetMaskEntries(block);
        QuantInterval=entries{1};


        funcSet=uReplaceBlock(h,block,'built-in/Quantizer',...
        'QuantizationInterval',QuantInterval);
        appendTransaction(h,block,h.ReplaceBlockReasonStr,{funcSet});
    end

end
