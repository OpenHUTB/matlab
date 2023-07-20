classdef NominalConditionsSpecification<int32





    enumeration
        NominalEffandPR(1)
        NominalTemps(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('NominalEffandPR')='Nominal pressure ratio';
            map('NominalTemps')='Nominal evaporating and condensing temperatures';
        end
    end
end