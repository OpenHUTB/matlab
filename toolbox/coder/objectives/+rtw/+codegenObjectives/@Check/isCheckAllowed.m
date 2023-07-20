

function isCheckAllowed(check,~)
    if nargin>0
        check=convertStringsToChars(check);
    end

    disallowedCheck=coder.advisor.internal.CGODisallowedCheck;
    dCheckhash=disallowedCheck.checkHash;

    if~isempty(dCheckhash.get(check))
        args{1}='disallowedCheck';
        args{2}=check;

        rtw.codegenObjectives.ObjectiveCustomizer.throwError(args);
    end
end
