function unaryMinusBlock(obj)







    if isR2009aOrEarlier(obj.ver)


        blockType='UnaryMinus';
        maskType='Unary Minus';
        fcnName='sfix_abs';
        refRule='simulink/Math\nOperations/Unary Minus';
        setFcn=@setupUnaryMinusBlock;


        pre2009aRules=blockToSFunction(obj,blockType,...
        maskType,...
        fcnName,...
        refRule,...
        setFcn);

        obj.appendRules(pre2009aRules);
    end

end


function maskVarNames=setupUnaryMinusBlock(sfcn)
    set_param(sfcn,...
    'Parameters','5,[DoSatur 3]',...
    'MaskVariables','DoSatur=@1;');

    maskVarNames={'DoSatur'};
end
