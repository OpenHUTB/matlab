function nesl_setvariant(block,sourceFile)




    variants=simscape.internal.variantsAndNames(block);

    if~any(strcmp(variants,sourceFile))
        pm_error('physmod:ne_sli:nesl_setvariant:InvalidVariant',...
        sourceFile,getfullname(block),strjoin(variants,', '));
    end

    set_param(block,'SourceFile',sourceFile,'ComponentPath',sourceFile);

end

