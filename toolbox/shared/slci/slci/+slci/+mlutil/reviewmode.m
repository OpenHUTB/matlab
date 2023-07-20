function reviewmode(mode)
























%#codegen
    coder.allowpcode('plain');
    if nargin<1||nargin>1
        DAStudio.error('Slci:slci:InvalidNumberOfArguments');
    else
        coder.internal.errorIf(~strcmp(mode,'manual'),'Slci:ui:InvalidManualReviewSetting');

    end

end

