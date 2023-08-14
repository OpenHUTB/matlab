classdef TriggerSpecification<dsp.webscopes.measurements.BaseMeasurementSpecification





    properties(AbortSet)
        Mode='auto';
        Type='edge';
        Rearm=true;
        AutoLevel=true;
        Position=50;
        Level=0;
        Hysteresis=0;
        HighLevel=2.3;
        LowLevel=0.2;
        MinPulseWidth=0;
        MaxPulseWidth=Inf;
        MinDuration=0;
        MaxDuration=Inf;
        Timeout=0;
        Delay=0;
        Holdoff=0;
        Channel=1;
    end

    properties(Dependent)
        Polarity;
    end

    properties(Access=protected)
        RisingFallingPolarity='rising';
        RiseTimeFallTimePolarity='rise-time';
        PostiveNegativePolarity='positive';
        InsideOutsidePolarity='inside';
    end



    methods


        function set.Polarity(this,value)
            if any(strcmpi(this.Type,{'pulse-width','runt'}))
                this.PostiveNegativePolarity=value;
            elseif strcmpi(this.Type,'transition')
                this.RiseTimeFallTimePolarity=value;
            elseif strcmpi(this.Type,'window')
                this.InsideOutsidePolarity=value;
            else
                this.RisingFallingPolarity=value;
            end
        end
        function value=get.Polarity(this)
            if any(strcmpi(this.Type,{'pulse-width','runt'}))
                value=this.PostiveNegativePolarity;
            elseif strcmpi(this.Type,'transition')
                value=this.RiseTimeFallTimePolarity;
            elseif strcmpi(this.Type,'window')
                value=this.InsideOutsidePolarity;
            else
                value=this.RisingFallingPolarity;
            end
        end


        function propValue=preprocessPropertyValue(~,propName,value)
            propValue=value;
            if any(strcmpi(propName,{'MinPulseWidth','MaxPulseWidth','MinDuration','MaxDuration'}))
                propValue=string(value);
            end
        end


        function settings=getSettings(this)
            settings=getSettings@dsp.webscopes.measurements.BaseMeasurementSpecification(this);
            settings.Mode=this.Mode;
            settings.Type=this.Type;
            settings.Polarity=this.Polarity;
            settings.Rearm=this.Rearm;
            settings.AutoLevel=this.AutoLevel;
            settings.Position=this.Position;
            settings.Level=this.Level;
            settings.Hysteresis=this.Hysteresis;
            settings.HighLevel=this.HighLevel;
            settings.LowLevel=this.LowLevel;
            settings.MinPulseWidth=string(this.MinPulseWidth);
            settings.MaxPulseWidth=string(this.MaxPulseWidth);
            settings.MinDuration=string(this.MinDuration);
            settings.MaxDuration=string(this.MaxDuration);
            settings.Timeout=this.Timeout;
            settings.Delay=this.Delay;
            settings.Holdoff=this.Holdoff;
            settings.Channel=this.Channel;
        end


        function S=toStruct(this)
            S=getSettings(this);
            S.MinPulseWidth=double(this.MinPulseWidth);
            S.MaxPulseWidth=double(this.MaxPulseWidth);
            S.MinDuration=double(this.MinDuration);
            S.MaxDuration=double(this.MaxDuration);
        end

        function flag=isInactiveProperty(this,propName)
            flag=false;
            switch propName
            case 'Rearm'
                flag=~strcmpi(this.Mode,'once');
            case{'Level','Hysteresis'}
                flag=this.AutoLevel;
            case{'HighLevel','LowLevel'}
                flag=any(strcmpi(this.Type,{'edge','timeout'}))&&this.AutoLevel;
            case{'MinPulseWidth','MaxPulseWidth'}
                flag=any(strcmpi(this.Type,{'edge','transition','window','timeout'}));
            case{'MinDuration','MaxDuration'}
                flag=any(strcmpi(this.Type,{'edge','pulse-width','runt','timeout'}));
            case 'Timeout'
                flag=~strcmpi(this.Type,'timeout');
            end
        end
    end



    methods(Hidden)

        function name=getMeasurementPropertyName(~)
            name='Trigger';
        end

        function name=getMeasurementName(~)
            name='Trigger';
        end
    end
end