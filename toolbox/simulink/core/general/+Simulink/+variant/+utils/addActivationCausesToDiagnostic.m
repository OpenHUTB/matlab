function err=addActivationCausesToDiagnostic(err,errors)








    for m=1:numel(errors)
        for e=1:numel(errors{m}.Errors)
            err=err.addCause(MException(errors{m}.Errors{e}.MessageID,errors{m}.Errors{e}.Message));
        end
    end
end
