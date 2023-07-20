function runCompTransformer(~,p)



    if(targetcodegen.targetCodeGenerationUtils.isFloatingPointMode())
        p.runCompTransformer();
        p.runVectorMACCompTransformer(false);
    end
end
