classdef freewheeling_mode<int32



    enumeration
        one_switch_one_diode(1)
        two_diodes(2)
        two_switches_one_diode(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('one_switch_one_diode')='physmod:ee:library:comments:enum:converters:freewheeling_mode:map_ViaOneSemiconductorSwitchAndOneFreewheelingDiode';
            map('two_diodes')='physmod:ee:library:comments:enum:converters:freewheeling_mode:map_ViaTwoFreewheelingDiodes';
            map('two_switches_one_diode')='physmod:ee:library:comments:enum:converters:freewheeling_mode:map_ViaTwoSemiconductorSwitchesAndOneFreewheelingDiode';
        end
    end
end
