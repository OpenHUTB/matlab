










classdef AppDose<hgsetget

    properties(Access=public)
        Name='';
        Target='';
        Amount=1;
        AmountMin=0;
        AmountMax=10;
        AmountUnits='';
        Interval=0;
        Rate=0;
        RateMin=0;
        RateMax=10;
        RateUnits='';
        Repeat=0;
        StartTime=0;
        Time=0;
        TimeUnits='';


        Type='';
    end

    methods
        function obj=AppDose(name)
            obj.Name=name;
        end
    end
end
