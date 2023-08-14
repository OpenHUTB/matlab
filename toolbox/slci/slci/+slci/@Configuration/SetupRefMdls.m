function SetupRefMdls(aObj)




    if Simulink.internal.useFindSystemVariantsMatchFilter()



        sub_model_names=find_mdlrefs(aObj.getModelName(),'MatchFilter',@Simulink.match.codeCompileVariants);
    else
        sub_model_names=find_mdlrefs(aObj.getModelName());
    end

    sub_model_names(end)='';
    aObj.setRefMdls(sub_model_names);
end

