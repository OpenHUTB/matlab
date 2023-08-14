classdef GroundOrPartialSpecificationUIProperties<starepository.ioitemproperty.ItemUIProperties



    properties(Constant,Hidden)


        NormalIcon='signal.gif';
        ErrorIcon='SignalError.png';

        WarningIcon='SignalWarning.png';
    end

    methods
        function obj=GroundOrPartialSpecificationUIProperties
            obj=obj@starepository.ioitemproperty.ItemUIProperties;
        end

    end

end

