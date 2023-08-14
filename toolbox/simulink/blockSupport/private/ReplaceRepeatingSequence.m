function ReplaceRepeatingSequence(block,h)




    if askToReplace(h,block)
        maskVar=get_param(block,'MaskVariables');
        funcSet={};

        if isempty(maskVar),

            pFuncSet=uSafeSetParam(h,block,...
            'MaskVariables','rep_seq_t=@1;rep_seq_y=@2;',...
            'MaskInitialization','period=max(rep_seq_t);'...
            );
            funcSet={pFuncSet};
        end

        rFuncSet=uReplaceBlockWithLink(h,block);
        funcSet{1,end+1}=rFuncSet;
        appendTransaction(h,block,h.ConvertToLinkReasonStr,funcSet);
    end

end
