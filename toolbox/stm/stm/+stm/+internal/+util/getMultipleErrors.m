

function[errorMessages,errorOrLog]=getMultipleErrors(me)
    numErrors=length(me.cause);

    errorMessages={};
    errorOrLog={};

    if~strcmp(me.identifier,'MATLAB:MException:MultipleErrors')
        errorMessages{end+1}=stm.internal.util.getDiagnosticMessage(me);
        errorOrLog{end+1}=true;
    end

    for e=1:numErrors

        [tempErrors,tempStatuses]=stm.internal.util.getMultipleErrors(me.cause{e});
        for j=1:length(tempErrors)
            errorMessages{end+1}=tempErrors{j};
            errorOrLog{end+1}=tempStatuses{j};
        end
    end
end
