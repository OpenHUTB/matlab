


function[InportUnitSymbol,OutportUnitSymbol]=getCompiledPortUnits(blkH)


    CompiledPortUnit=(get_param(blkH,'CompiledPortUnits'));


    CompiledPortInportUnit=cell2mat(strtrim(CompiledPortUnit.Inport));
    CompiledPortOutportUnit=cell2mat(strtrim(CompiledPortUnit.Outport));


    InportUnitSymbol=getCompiledPortUnitSymbol(CompiledPortInportUnit);
    OutportUnitSymbol=getCompiledPortUnitSymbol(CompiledPortOutportUnit);

end



function[UnitSymbol]=getCompiledPortUnitSymbol(CompiledPortUnit)


    switch(CompiledPortUnit)
    case{'percent','%'}
        UnitSymbol='percent';
    case{'one','1'}
        UnitSymbol='one';
    case 'degree'
        UnitSymbol='deg';
    case 'radian'
        UnitSymbol='rad';

    case{'degree_Celsius',strcat(char(176),'C'),'Celsius'}
        UnitSymbol='degC';
    case{'degree_Fahrenheit',strcat(char(176),'F'),'Fahrenheit'}
        UnitSymbol='degF';
    case{'kelvin'}
        UnitSymbol='K';
    case{'rankine',strcat(char(916),char(176),'R')}
        UnitSymbol='degR';

    case{'delta_Celsius',strcat(char(916),char(176),'C')}
        UnitSymbol='deltadegC';
    case{'delta_Fahrenheit',strcat(char(916),char(176),'F')}
        UnitSymbol='deltadegF';
    case{'delta_kelvin',strcat(char(916),'K')}
        UnitSymbol='deltaK';
    case{'delta_rankine',strcat(char(916),char(176),'R')}
        UnitSymbol='deltadegR';
    case 'foot'
        UnitSymbol='ft';
    case{'meter','metre'}
        UnitSymbol='m';
    case 'mile'
        UnitSymbol='mi';
    case{'nautical_mile','nmi'}
        UnitSymbol='M';
    case 'kilogram'
        UnitSymbol='kg';
    case 'pound_mass'
        UnitSymbol='lbm';
    case 'pound_force'
        UnitSymbol='lbf';
    case{'newton','kg*m/s^2'}
        UnitSymbol='N';
    case 'inches_of_mercury'
        UnitSymbol='inHg';
    case 'millimeters_of_mercury'
        UnitSymbol='mmHg';
    case 'knot'
        UnitSymbol='kn';
    case{'mile_per_hour','mi/h','mi/hr'}
        UnitSymbol='mph';
    case{'foot_per_second','ft/s','ft/sec'}
        UnitSymbol='fps';
    case 'sec'
        UnitSymbol='s';
    case 'msec'
        UnitSymbol='ms';
    case 'lbf/h'
        UnitSymbol='lbf/hr';
    case 'lbf/s'
        UnitSymbol='lbf/sec';
    case 'lbm/h'
        UnitSymbol='lbm/hr';
    case 'lbm/s'
        UnitSymbol='lbm/sec';
    otherwise
        UnitSymbol=CompiledPortUnit;
    end
end




