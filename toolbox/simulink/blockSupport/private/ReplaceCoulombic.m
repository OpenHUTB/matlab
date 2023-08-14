function ReplaceCoulombic(block,h)





    if askToReplace(h,block)
        maskVar=get_param(block,'MaskVariables');
        funcSet={};

        if(isempty(maskVar))

            pFuncSet=uSafeSetParam(h,block,...
            'MaskVariables','offset=@1;gain=@2;',...
            'MaskInitialization','x=max(offset(1),gain(1)+offset(1));'...
            );
            funcSet={pFuncSet};
        end

        rFuncSet=uReplaceBlockWithLink(h,block);
        funcSet{1,end+1}=rFuncSet;
        appendTransaction(h,block,h.ReplaceBlockReasonStr,funcSet);
    end

end
