



function deriveTraceSubstatus(obj)









    switch(obj.getStatus())
    case 'VERIFIED'
        if~isempty(obj.getTraceArray())
            obj.addPrimTraceSubstatus('TRACED');
        end
    case 'UNABLE_TO_PROCESS'
        obj.addPrimTraceSubstatus(...
        'VERIFICATION_UNABLE_TO_PROCESS');
    case 'FAILED_TO_VERIFY'
        obj.addPrimTraceSubstatus(...
        'VERIFICATION_FAILED_TO_VERIFY');
    case 'PARTIALLY_PROCESSED'
        obj.addPrimTraceSubstatus(...
        'VERIFICATION_PARTIALLY_PROCESSED');
    case 'UNEXPECTED'
        obj.addPrimTraceSubstatus(...
        'VERIFICATION_UNEXPECTED')
    case 'UNEXPECTEDDEF'
        obj.addPrimTraceSubstatus('VERIFICATION_UNEXPECTEDDEF');
    case 'WAW'
        obj.addPrimTraceSubstatus('VERIFICATION_WAW');
    case 'MANUAL'
        obj.addPrimTraceSubstatus('VERIFICATION_MANUAL');
    case 'JUSTIFIED'
        obj.addPrimTraceSubstatus('JUSTIFIED');
    case 'UNKNOWN'
        DAStudio.error('Slci:results:InvalidStatus',obj.getStatus());
    end

    aggSubstatus=obj.aggTraceSubstatus();
    obj.setTraceSubstatus(aggSubstatus);
    if strcmpi(aggSubstatus,'UNKNOWN')
        DAStudio.error('Slci:results:ErrorDerivingTraceSubstatus',obj.getKey());
    end

end
