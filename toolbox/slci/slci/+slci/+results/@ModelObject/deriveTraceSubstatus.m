


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
    case 'JUSTIFIED'
        obj.addPrimTraceSubstatus('JUSTIFIED');
    case{'UNKNOWN'}
        DAStudio.error('Slci:results:InvalidStatus',obj.getStatus());
    end


    aggSubstatus=obj.aggTraceSubstatus();
    if strcmpi(aggSubstatus,'UNKNOWN')
        DAStudio.error('Slci:results:ErrorDerivingTraceSubstatus',obj.getKey());
    end

    obj.setTraceSubstatus(aggSubstatus);

end
