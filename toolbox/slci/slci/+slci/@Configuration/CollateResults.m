




function summary=CollateResults(aObj,displayMessage,Result,...
    Incompatibilities,FatalIncompatibility,TerminateOnIncompatibility)

    if displayMessage
        disp(' ');
        if(Result==0)
            msg=message('Slci:slci:INSPECTION_PASSED',aObj.getModelName());
        else
            msg=message('Slci:slci:INSPECTION_FAILED',aObj.getModelName());
        end
        disp(msg.getString);
    end
    summary.Code=Result;
    summary.Incompatibilities=Incompatibilities;
    summary.isFatal=FatalIncompatibility;
    summary.TerminateOnIncompatibility=TerminateOnIncompatibility;
    summary.Mdl=aObj.getModelName();
end
