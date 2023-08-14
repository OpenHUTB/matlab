function fundamentalValue=utilUnitConversion(value,unit)




    fundamentalUnit=pm_fundamentalunit(unit);

    conversion=pm_unit(unit,fundamentalUnit);

    fundamentalValue=value*conversion(1)+conversion(2);

end

