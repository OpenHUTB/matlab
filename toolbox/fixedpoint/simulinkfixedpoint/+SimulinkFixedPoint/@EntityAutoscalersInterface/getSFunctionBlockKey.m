function key=getSFunctionBlockKey(~,blk)


    mask='';
    try
        mask=blk.MaskType;
    catch

    end

    if isempty(mask)




        sfunName=get_param(blk.handle,'FunctionName');



        mask=[sfunName,'RawSFunWithoutMask'];
    end

    key=[mask,':',class(blk)];
end