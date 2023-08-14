function evalTestBenchResult(aTBR)




    identifier='Coder:FE:TestBenchFail';
    noFailure=true;

    msg='';
    if isa(aTBR,'MException')
        errStruct=MException(identifier,'');
        errStruct=errStruct.addCause(aTBR);
        throw(errStruct);
    else
        for i=1:numel(aTBR)
            if aTBR(i).Failed||aTBR(i).Incomplete
                if isprop(aTBR(i).Details.DiagnosticRecord,'Exception')
                    msg=[msg,message(identifier,aTBR(i).Name,aTBR(i).Details.DiagnosticRecord.Exception.message).getString];%#ok<AGROW>
                    noFailure=false;
                else
                    msg=[msg,message(identifier,aTBR(i).Name,aTBR(i).Details.DiagnosticRecord.Event).getString];%#ok<AGROW>
                    if~strcmp(aTBR(i).Details.DiagnosticRecord.Event,'AssumptionFailed')
                        noFailure=false;
                    end
                end
            end
        end
        if~noFailure
            throw(MException(identifier,msg));
        else
            disp(aTBR);
            disp(aTBR.table);
        end
    end
