function HtoIL_set_block_files(block,RefBlock)













    pDest=Simulink.Mask.get(block);
    if~isempty(pDest)&&~isempty(pDest.BaseMask)
        blockHasMask=1;
        path=getfullname(block);
        hTemp=add_block(path,path,'MakeNameUnique','on');
        set_param(hTemp,'LinkStatus','none');
        pSource=Simulink.Mask.get(hTemp);
    else
        blockHasMask=0;
    end

    try
        set_param(block,'ReferenceBlock',RefBlock)
        set_param(block,'SourceFile',get_param(RefBlock,'SourceFile'))
        set_param(block,'ComponentPath',get_param(RefBlock,'ComponentPath'))
        set_param(block,'ComponentVariants',get_param(RefBlock,'ComponentVariants'))
        set_param(block,'ComponentVariantNames',get_param(RefBlock,'ComponentVariantNames'))
    catch ME
    end

    if blockHasMask
        pDest=Simulink.Mask.get(block);
        if isempty(pDest)||isempty(pDest.BaseMask)
            pDest=Simulink.Mask.create(block);
        end
        pDest.copy(pSource);

        delete_block(hTemp);
    end
end
