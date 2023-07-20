function[descTitle,descText]=nesl_getblockdescription(hBlk)






    if simscape.engine.sli.internal.issimscapeblock(hBlk)
        comp=simscape.getBlockComponent(hBlk);
        try

            cs=physmod.schema.internal.blockComponentSchema(hBlk,comp);
            i=cs.info();
            descTitle=pm.sli.internal.cleanGroupLabel(i.Descriptor);
            descText=i.Description;
        catch


            [descTitle,descText]=nesl_getbasiccomponentinfo(comp);
        end
    else
        descTitle=get_param(hBlk,'MaskType');
        descText=pm.sli.internal.resolveMessageString(...
        get_param(hBlk,'MaskDescription'));
    end

end
