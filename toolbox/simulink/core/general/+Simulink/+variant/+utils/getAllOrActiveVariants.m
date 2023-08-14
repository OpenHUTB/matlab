function variantChoiceType=getAllOrActiveVariants(calledFromTool,calledFromReducer)










    if calledFromReducer


        variantChoiceType='ActiveVariants';
    else
        if calledFromTool


            variantChoiceType='AllVariants';
        else


            variantChoiceType='ActivePlusCodeVariants';
        end
    end
end