








function isEnabled=isValidatorEnabled(aOpts,aSimMode)
    if nargin<2
        aSimMode=[];
    end

    isEnabled=slavteng('feature','ReportApproximationIncr');
    isEnabled=isEnabled&&slavteng('feature','ReportApproximation');
    isEnabled=isEnabled&&(~strcmp(aOpts.Mode,'DesignErrorDetection')||...
    slavteng('feature','DedValidation')||...
    (Sldv.utils.isActiveLogic(aOpts)&&slfeature('SldvValidateActiveLogic')));

    if SlCov.CovMode.isXIL(aSimMode)
        isEnabled=isEnabled&&slavteng('feature','SILValidation');
    end
end
