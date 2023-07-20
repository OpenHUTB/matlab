function ReplaceChirp(block,h)





    if askToReplace(h,block)
        maskVar=get_param(block,'MaskVariables');
        funcSet={};
        if isempty(maskVar)

            pFuncSet=uSafeSetParam(h,block,...
            'MaskVariables','f1=@1;T=@2;f2=@3;',...
            'MaskInitialization','t=[0:.1:5];'...
            );
            funcSet={pFuncSet};
        end

        rFuncSet=uReplaceBlockWithLink(h,block);
        funcSet{end+1}=rFuncSet;
        appendTransaction(h,block,h.ReplaceBlockReasonStr,funcSet);
    end

end
