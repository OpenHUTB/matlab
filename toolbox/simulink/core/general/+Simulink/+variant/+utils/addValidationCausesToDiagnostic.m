function err=addValidationCausesToDiagnostic(err,causes)














    function status=checkIfStructAndHasField(aStruct,aField)
        status=isa(aStruct,'struct')&&isfield(aStruct,aField);
    end


    Simulink.variant.utils.reportDiagnosticIfV2Enabled();

    for ii=1:numel(causes)

        if isa(causes{ii},'MException')
            err=err.addCause(causes{ii});
            continue;
        end

        if~checkIfStructAndHasField(causes{ii},'Errors')
            continue;
        end

        errorArrayOfStructs=causes{ii}.Errors;
        for ij=1:numel(errorArrayOfStructs)

            if~checkIfStructAndHasField(errorArrayOfStructs{ij},'Exception')
                continue;
            end



            err=err.addCause(errorArrayOfStructs{ij}.Exception);
        end
    end
end


