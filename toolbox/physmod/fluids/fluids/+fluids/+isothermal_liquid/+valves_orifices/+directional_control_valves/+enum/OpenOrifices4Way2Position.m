classdef OpenOrifices4Way2Position<int32






    enumeration
        AllClosed(0)
        PA_BT(1)
        PA_PB(2)
        PB_AT(3)
        PA(4)
        PB(5)
        PA_PB_AT_BT(6)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('AllClosed')='All closed';
            map('PA_BT')='P-A and B-T';
            map('PA_PB')='P-A and P-B';
            map('PB_AT')='P-B and A-T';
            map('PA')='P-A only';
            map('PB')='P-B only';
            map('PA_PB_AT_BT')='P-A, P-B, A-T, and B-T ';
        end
    end

end