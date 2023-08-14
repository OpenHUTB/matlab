function flag=defaultVariantExists(blockPath)




    flag=false;

    varCtrls=get_param(blockPath,'VariantControls');

    for ii=1:numel(varCtrls)
        flag=strcmp(Simulink.variant.keywords.getDefaultVariantKeyword(),varCtrls{ii});
        if flag
            return;
        end
    end

end
