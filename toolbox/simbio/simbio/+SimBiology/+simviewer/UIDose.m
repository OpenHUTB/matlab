










classdef UIDose<SimBiology.simviewer.UIPanel

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
        TimeUnits='';
        Time=0;
        Type='';


        ShowAmountRange=false;
        ShowRateRange=false;


        InvalidTime=false;
        InvalidAmount=false;
        InvalidRate=false;
    end

    methods
        function obj=UIDose(model)
            obj.Name=model.Name;
            obj.Target=model.Target;
            obj.Amount=model.Amount;
            obj.AmountMin=model.AmountMin;
            obj.AmountMax=model.AmountMax;
            obj.AmountUnits=model.AmountUnits;
            obj.Interval=model.Interval;
            obj.Rate=model.Rate;
            obj.RateMin=model.RateMin;
            obj.RateMax=model.RateMax;
            obj.RateUnits=model.RateUnits;
            obj.Repeat=model.Repeat;
            obj.StartTime=model.StartTime;
            obj.TimeUnits=model.TimeUnits;
            obj.Time=model.Time;
            obj.Type=model.Type;
        end

        function str=getLabel(obj)
            str=[obj.Name,' (',obj.Target,')'];
        end
    end
end