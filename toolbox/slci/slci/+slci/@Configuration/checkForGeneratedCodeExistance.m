function checkForGeneratedCodeExistance(aObj)





    suffix=aObj.getTargetLangSuffix();
    modelDotC=fullfile(aObj.getDerivedCodeFolder(),...
    [aObj.getModelName(),suffix]);
    if~exist(modelDotC,'file')
        DAStudio.error('Slci:slci:ERRORS_DOTC',modelDotC);
    end
end


