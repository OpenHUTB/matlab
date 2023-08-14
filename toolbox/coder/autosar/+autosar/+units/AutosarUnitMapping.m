classdef AutosarUnitMapping






    properties(Constant)

        ARFundamentalDims={'l','m','t','I','T','n','L'};
        SLPhysicalQuantity={'length','mass','time','electric_current','thermodynamic_temperature','amount_of_substance','luminous_intensity'};
        SLFundamentalSIUnitSymbols={'m','kg','s','A','K','mol','ca'};
        ARFundementalSIUnitSymbols={'m','kg','s','A','K','mol','cd'};

        ARDimsToSLPhysQuantity=containers.Map(...
        autosar.units.AutosarUnitMapping.ARFundamentalDims,...
        autosar.units.AutosarUnitMapping.SLPhysicalQuantity);

        ARFundementalDimsToSLSIUnits=containers.Map(...
        autosar.units.AutosarUnitMapping.ARFundamentalDims,...
        autosar.units.AutosarUnitMapping.SLFundamentalSIUnitSymbols);
    end
end


