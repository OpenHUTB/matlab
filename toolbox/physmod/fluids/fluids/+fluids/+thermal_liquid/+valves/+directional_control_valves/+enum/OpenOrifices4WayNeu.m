classdef OpenOrifices4WayNeu<int32





    enumeration
        all_closed(0)
        PA_PB_AT_BT(1)
        AT_BT(2)
        PA_AT(3)
        PA_BT(4)
        PA_PB(5)
        PB_AT(6)
        PB_BT(7)
        AT(8)
        BT(9)
        PA(10)
        PB(11)
        PT(12)
        PA_AT_PT(13)
        PA_PB_AB(14)
        PB_BT_PT(15)
        PA_PB_AT_BT_PT(16)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('all_closed')='All closed';
            map('PA_PB_AT_BT')='P-A, P-B, A-T, and B-T ';
            map('AT_BT')='A-T and B-T';
            map('PA_AT')='P-A and A-T';
            map('PA_BT')='P-A and B-T';
            map('PA_PB')='P-A and P-B';
            map('PB_AT')='P-B and A-T';
            map('PB_BT')='P-B and B-T';
            map('AT')='A-T only';
            map('BT')='B-T only';
            map('PA')='P-A only';
            map('PB')='P-B only';
            map('PT')='P-T only';
            map('PA_AT_PT')='P-A, A-T, and P-T';
            map('PA_PB_AB')='P-A, P-B, and A-B';
            map('PB_BT_PT')='P-B, B-T, and P-T';
            map('PA_PB_AT_BT_PT')='P-A, P-B, A-T, B-T, P-T';
        end
    end

end