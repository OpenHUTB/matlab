classdef Status





    enumeration

Unset

Implemented
PartiallyImplemented
JustStarted
AlmostDone

Pass
Fail
Unexecuted

Justified
None
Excluded
Container

Justification
    end

    methods
        function out=getFiledName(enumVal)



            switch enumVal
            case slreq.analysis.Status.Pass
                out='passed';
            case slreq.analysis.Status.Fail
                out='failed';
            otherwise
                out=lower(char(enumVal));
            end
        end
    end
end
