classdef OpenOrifices3Way<int32





    enumeration
        all_closed(0)
        PA_AT_PT(1)
        PA(2)
        AT(3)
        PT(4)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('all_closed')='All closed';
            map('PA_AT_PT')='P-A, A-T, and P-T';
            map('PA')='P-A only';
            map('AT')='A-T only';
            map('PT')='P-T only';
        end
    end

end