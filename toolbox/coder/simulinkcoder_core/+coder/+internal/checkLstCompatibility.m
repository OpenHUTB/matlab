function checkLstCompatibility(model)






    i_checkWordSizeSettings(model);


    if strcmp(get_param(model,'IsERTTarget'),'off')
        DAStudio.error('RTW:buildProcess:LstRequiresERT',model);
    end


    if strcmp(get_param(model,'ExtMode'),'on')
        DAStudio.error('RTW:buildProcess:LstExtModeCompatibility',model);
    end


    if strcmp(get_param(model,'EnableUserReplacementTypes'),'on')
        DAStudio.error('RTW:buildProcess:LstDtrCompatibility',model);
    end


    if strcmp(get_param(model,'TargetLangStandard'),'C89/C90 (ANSI)')
        DAStudio.error('RTW:buildProcess:LstC89Compatibility',model);
    end

    function i_checkWordSizes(model,wordSizes)
        if any(setdiff([8,16,32],wordSizes))
            DAStudio.error("RTW:buildProcess:StandardTypesCompatibility",model);
        elseif any(setdiff(wordSizes,[8,16,32,64]))
            DAStudio.error("RTW:buildProcess:StandardTypesCompatibility",model);
        end



        function i_checkWordSizeSettings(model)

            targetWordSizes=[
            get_param(model,'TargetBitPerChar')
            get_param(model,'TargetBitPerShort')
            get_param(model,'TargetBitPerInt')
            get_param(model,'TargetBitPerLong')];
            if strcmp(get_param(model,'TargetLongLongMode'),'on')
                targetWordSizes(end+1)=get_param(model,'TargetBitPerLongLong');
            end
            i_checkWordSizes(model,targetWordSizes);

            if~strcmp(model,'ProdEqTarget')

                prodWordSizes=[
                get_param(model,'ProdBitPerChar')
                get_param(model,'ProdBitPerShort')
                get_param(model,'ProdBitPerInt')
                get_param(model,'ProdBitPerLong')];
                if strcmp(get_param(model,'ProdLongLongMode'),'on')
                    prodWordSizes(end+1)=get_param(model,'ProdBitPerLongLong');
                end
                i_checkWordSizes(model,prodWordSizes);
            end



