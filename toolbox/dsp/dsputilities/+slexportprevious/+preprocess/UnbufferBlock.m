function UnbufferBlock(obj)







    if isR2010aOrEarlier(obj.ver)
        blockType='Unbuffer';
        maskType='Unbuffer';
        fcnName='sdsprebuff2';
        refRule='dspbuff3/Unbuffer';
        setFcn=@setupUnbufferBlock;

        obj.appendRules(blockToSFunction(obj,blockType,...
        maskType,...
        fcnName,...
        refRule,...
        setFcn));

    end
end


function maskVarNames=setupUnbufferBlock(sfcn)




    set_param(sfcn,...
    'Parameters','ic',...
    'MaskVariables','ic=@1;');

    maskVarNames={'ic'};
end
