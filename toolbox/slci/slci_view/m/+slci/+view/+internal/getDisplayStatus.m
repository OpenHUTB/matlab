

function out=getDisplayStatus(input)
    out=input;
    switch input
    case{'VERIFIED','TRACED'}
        out='PASSED';
    case{'PARTIALLY_VERIFIED'}
        out='WARNING';
    case{'FAILED_TO_VERIFY'}
        out='FAILED';
    end

end