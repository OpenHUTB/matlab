classdef directional_valve_open_orifices_pos_neg<int32






    enumeration
        PA_BT(1)
        PA_PB(2)
        PB_AT(3)
        PA(4)
        PB(5)
        PA_PB_AB(6)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('PA_BT')='P-A and B-T';
            map('PA_PB')='P-A and P-B';
            map('PB_AT')='P-B and A-T';
            map('PA')='P-A only';
            map('PB')='P-B only';
            map('PA_PB_AB')='P-A, P-B, and A-B';
        end
    end

end