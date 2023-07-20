



classdef isothermal_liquid_fluid_list<int32

    enumeration
        water(1)
        mitsw(2)
        ethylene_glycol(3)
        propylene_glycol(4)
        glycerol(5)
        jet_A(6)
        diesel(7)
        sae5w30(8)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('water')='Water';
            map('mitsw')='Seawater (MIT model)';
            map('ethylene_glycol')='Ethylene glycol and water mixture';
            map('propylene_glycol')='Propylene glycol and water mixture';
            map('glycerol')='Glycerol and water mixture';
            map('jet_A')='Aviation fuel Jet-A';
            map('diesel')='Diesel fuel';
            map('sae5w30')='SAE 5W-30';
        end
    end

end