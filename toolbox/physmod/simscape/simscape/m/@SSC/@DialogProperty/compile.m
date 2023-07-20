function compile(dp,previous)




    ;



    units=l_get_units(previous.Name);
    if strcmp(dp.getGroup,previous.getGroup)&&strcmp(dp.Name,[previous.Name,'Units'])&&~isempty(units)
        dp.WidgetType='units';
        dp.Entries=units;
        dp.IsUnit=true;
        previous.HasUnit=true;
    end

    function units=l_get_units(name)



        switch name
        case 'Gravity'
            units={'km/s^2','m/s^2','cm/s^2','mm/s^2','mi/s^2','ft/s^2','in/s^2'};
        case 'LinearAssemblyTolerance'
            units={'km','m','cm','mm','mi','ft','in'};
        case 'AngularAssemblyTolerance'
            units={'deg','rad'};
        otherwise
            units={};
        end






