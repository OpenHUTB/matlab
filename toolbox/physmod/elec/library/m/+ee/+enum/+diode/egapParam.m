classdef egapParam<int32





    enumeration
        material_si(1)
        material_4h_sic(2)
        material_6h_sic(3)
        material_ge(4)
        material_gaas(5)
        material_se(6)
        material_schottky(7)
        custom(8)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('material_si')='physmod:ee:library:comments:enum:diode:egapParam:map_UseNominalValueForSiliconEG111eV';
            map('material_4h_sic')='physmod:ee:library:comments:enum:diode:egapParam:map_UseNominalValueFor4HSiCSiliconCarbideEG323eV';
            map('material_6h_sic')='physmod:ee:library:comments:enum:diode:egapParam:map_UseNominalValueFor6HSiCSiliconCarbideEG300eV';
            map('material_ge')='physmod:ee:library:comments:enum:diode:egapParam:map_UseNominalValueForGermaniumEG067eV';
            map('material_gaas')='physmod:ee:library:comments:enum:diode:egapParam:map_UseNominalValueForGalliumArsenideEG143eV';
            map('material_se')='physmod:ee:library:comments:enum:diode:egapParam:map_UseNominalValueForSeleniumEG174eV';
            map('material_schottky')='physmod:ee:library:comments:enum:diode:egapParam:map_UseNominalValueForSchottkyBarrierDiodesEG069eV';
            map('custom')='physmod:ee:library:comments:enum:diode:egapParam:map_SpecifyACustomValue';
        end
    end
end
