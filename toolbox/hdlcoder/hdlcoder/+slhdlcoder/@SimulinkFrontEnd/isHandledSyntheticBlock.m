function handled=isHandledSyntheticBlock(slbh)





    handled=false;

    if slhdlcoder.SimulinkFrontEnd.isSyntheticBlock(slbh)
        typ=get_param(slbh,'BlockType');
        if(strcmp(typ,'Ground')||strcmp(typ,'Terminator')||...
            (slfeature('STVariantsInHDL')>0&&strcmp(typ,'VariantMerge')))
            handled=true;
        end
    end
