function ReplacePID2(block,h)




    if askToReplace(h,block)

        maskVar=get_param(block,'MaskVariables');
        funcSet={};
        if isempty(maskVar)&&(doUpdate(h))

            pFuncSet=uSafeSetParam(h,block,...
            'MaskVariables','P=@1;I=@2;D=@3;N=@4;',...
            'MaskInitialization',''...
            );
            funcSet={pFuncSet};
        end

        rFuncSet=uReplaceBlockWithLink(h,block);
        funcSet{end+1}=rFuncSet;
        appendTransaction(h,block,h.ReplaceBlockReasonStr,funcSet);
    end

end
