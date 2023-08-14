function ReplaceMatrixGain(block,h)





    if askToReplace(h,block)
        maskVar=get_param(block,'MaskVariables');

        if isempty(maskVar)

            gainValStr=get_param(block,'MaskValues');
            try
                gainVal=eval(gainValStr{1});
            catch %#ok<CTCH>
                gainVal=gainValStr{1};
            end
        else
            gainVal=get_param(block,'K');
        end

        bFuncSet=uReplaceBlockWithLink(h,block);
        cFuncSet=uSafeSetParam(h,block,'Gain',gainVal);

        appendTransaction(h,block,h.ReplaceBlockReasonStr,{bFuncSet,cFuncSet});
    end

end
