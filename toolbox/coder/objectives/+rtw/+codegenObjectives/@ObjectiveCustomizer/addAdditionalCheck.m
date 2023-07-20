


function addAdditionalCheck(obj,checkID)
    fixedCheck=coder.advisor.internal.CGOFixedCheck;
    checkHash=fixedCheck.checkHash;
    args=cell(1,2);

    existing=0;
    failure=[];

    if~isempty(checkHash.get(checkID))
        failure.checkID=checkID;
        failure.reason=1;
        existing=1;
    else
        for j=1:length(obj.additionalCheck)
            if strcmp(obj.additionalCheck{j},checkID)
                existing=1;
                failure.checkID=obj.additionalCheck{j};
                failure.reason=2;
                break;
            end
        end
    end

    if existing
        switch failure.reason
        case 1
            args{1}='PreDefinedCheckError';
        case 2
            args{1}='ExistingAdditionalCheckError';
        end

        args{2}=failure.checkID;
        rtw.codegenObjectives.ObjectiveCustomizer.throwError(args);
    end

    obj.additionalCheck{end+1}=checkID;
end
