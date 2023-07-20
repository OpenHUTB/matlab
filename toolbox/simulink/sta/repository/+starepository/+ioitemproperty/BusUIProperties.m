classdef BusUIProperties<starepository.ioitemproperty.ItemUIProperties




    properties(Constant,Hidden)
        NormalIcon='bus.gif';
        ErrorIcon='BusError.png';

        WarningIcon='BusWarning.png';
    end

    methods
        function obj=BusUIProperties
            obj=obj@starepository.ioitemproperty.ItemUIProperties;
        end

    end

end

