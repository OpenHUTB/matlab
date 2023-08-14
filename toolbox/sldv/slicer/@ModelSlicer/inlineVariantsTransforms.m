function inlineVariantsTransforms(obj,hasMdlRef,sliceXfrmr,replaceModelBlockH,hdls,origSys,sliceRootSys)




    import Transform.*;
    if obj.options.InlineOptions.Variants
        copyVariantSSToSystem(sliceXfrmr,hdls,origSys,sliceRootSys,obj.options,replaceModelBlockH);
        removeInactiveInlineVariants(sliceXfrmr,origSys,sliceRootSys,obj.options,replaceModelBlockH);
        if hasMdlRef&&~obj.options.InlineOptions.ModelBlocks

            try
                mapModelBlockH=getCopyHandles(replaceModelBlockH,obj.refMdlToMdlBlk,origSys,sliceRootSys);
                for i=1:length(mapModelBlockH)
                    if strcmp(get_param(mapModelBlockH(i),'Variant'),'on')
                        slInternal('disableVariant',mapModelBlockH);
                    end
                end
            catch Mex
            end
        end
    end
end
