function polyvalBlocks(obj)







    if isR2007aOrEarlier(obj.ver)

        blockType='Polyval';
        maskType='Polyval';
        fcnName='sfun_polyval';
        refRule='simulink/Math\nOperations/Polynomial';
        setFcn=@setupPolyvalBlock;

        pre2007aRules=blockToSFunction(obj,blockType,...
        maskType,...
        fcnName,...
        refRule,...
        setFcn);

        obj.appendRules(pre2007aRules);


    end

end


function maskVarNames=setupPolyvalBlock(sfcn)
    set_param(sfcn,...
    'Parameters','coefs',...
    'MaskVariables','coefs=@1;');

    maskVarNames={'Coefs'};
end
