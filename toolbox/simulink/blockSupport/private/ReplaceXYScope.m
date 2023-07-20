function ReplaceXYScope(block,h)





    if askToReplace(h,block)
        maskVar=get_param(block,'MaskVariables');
        funcSet={};
        if isempty(maskVar)||...
            strcmp(maskVar,'ax(1)=@1;ax(2)=@2;ax(3)=@3;ax(4)=@4;st=@5;'),



            if strcmp(get_param(block,'MaskInitialization'),...
                'ax = [@1, @2, @3, @4];st=-1;'),
                valFlag=true;
            else
                valFlag=false;
            end


            aFuncSet=uSafeSetParam(h,block,...
            'MaskVariables','xmin=@1;xmax=@2;ymin=@3;ymax=@4;st=@5;',...
            'MaskInitialization',''...
            );
            funcSet={aFuncSet};

            if valFlag,
                vals=get_param(block,'MaskValues');
                vals{5}='-1';
                bFuncSet=uSafeSetParam(h,block,'MaskValues',vals);
                funcSet{2}=bFuncSet;
            end

        end

        cFuncSet=uReplaceBlockWithLink(h,block);
        funcSet{end+1}=cFuncSet;
        appendTransaction(h,block,h.ReplaceBlockReasonStr,funcSet);
    end

end
