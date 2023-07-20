function ReplaceRamp(block,h)





    if askToReplace(h,block)
        maskVar=get_param(block,'MaskVariables');
        funcSet={};
        if isempty(maskVar)&&(doUpdate(h))

            pFuncSet=uSafeSetParam(h,block,...
            'MaskVariables','slope=@1;start=@2;X0=@3;',...
            'MaskInitialization',''...
            );
            funcSet={pFuncSet};
        end

        rFuncSet=uReplaceBlockWithLink(h,block);
        funcSet{end+1}=rFuncSet;
        appendTransaction(h,block,h.ReplaceBlockReasonStr,funcSet);
    end

end
