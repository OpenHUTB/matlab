classdef TriggerConfiguration<dsp.webscopes.measurements.BaseMeasurementConfiguration


































    properties(AbortSet,Dependent)




        Mode;




        Type;










        Polarity;



        AutoLevel;




        Position;




        Level;




        Hysteresis;





        LowLevel;





        HighLevel;




        MinPulseWidth;




        MaxPulseWidth;





        MinDuration;





        MaxDuration;




        Timeout;



        Delay;



        Holdoff;



        Channel;
    end

    properties(Constant,Hidden)

        ModeSet={'auto','normal','once'};
        TypeSet={'edge','pulse-width','transition','runt','window','timeout'};
        PolaritySet={'rising','falling','either'};
        PulseWidthAndRuntPolaritySet={'positive','negative','either'};
        TransitionPolaritySet={'rise-time','fall-time','either'};
        WindowPolaritySet={'inside','outside','either'};
    end



    methods

        function this=TriggerConfiguration(hSpec)
            if nargin>0
                this.Specification=hSpec;
            else
                this.Specification=dsp.webscopes.measurements.TriggerSpecification;
            end
        end


        function set.Mode(this,value)
            value=convertStringsToChars(value);
            value=validateEnum(this,'Mode',value);
            setPropertyValue(this.Specification,'Mode',value);
        end
        function value=get.Mode(this)
            value=getPropertyValue(this.Specification,'Mode');
        end


        function set.Type(this,value)
            value=convertStringsToChars(value);
            value=validateEnum(this,'Type',value);
            setPropertyValue(this.Specification,'Type',value);
        end
        function value=get.Type(this)
            value=getPropertyValue(this.Specification,'Type');
        end


        function set.Polarity(this,value)
            value=convertStringsToChars(value);
            value=validateEnum(this,'Polarity',value);
            setPropertyValue(this.Specification,'Polarity',value);
        end
        function value=get.Polarity(this)
            value=getPropertyValue(this.Specification,'Polarity');
        end


        function set.AutoLevel(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','AutoLevel');
            setPropertyValue(this.Specification,'AutoLevel',value);
        end
        function value=get.AutoLevel(this)
            value=getPropertyValue(this.Specification,'AutoLevel');
        end


        function set.Position(this,value)
            validateattributes(value,{'numeric'},...
            {'positive','real','scalar','>=',0,'<=',100,'finite','nonnan'},'','Position');
            setPropertyValue(this.Specification,'Position',value);
        end
        function value=get.Position(this)
            value=getPropertyValue(this.Specification,'Position');
        end


        function set.Level(this,value)
            validateattributes(value,{'numeric'},...
            {'real','scalar','finite','nonnan'},'','Level');
            setPropertyValue(this.Specification,'Level',value);
        end
        function value=get.Level(this)
            value=getPropertyValue(this.Specification,'Level');
        end


        function set.Hysteresis(this,value)
            validateattributes(value,{'numeric'},...
            {'real','scalar','finite','nonnan'},'','Hysteresis');
            setPropertyValue(this.Specification,'Hysteresis',value);
        end
        function value=get.Hysteresis(this)
            value=getPropertyValue(this.Specification,'Hysteresis');
        end


        function set.LowLevel(this,value)
            validateattributes(value,{'numeric'},...
            {'real','scalar','finite','nonnan'},'','LowLevel');
            setPropertyValue(this.Specification,'LowLevel',value);
        end
        function value=get.LowLevel(this)
            value=getPropertyValue(this.Specification,'LowLevel');
        end


        function set.HighLevel(this,value)
            validateattributes(value,{'numeric'},...
            {'real','scalar','finite','nonnan'},'','HighLevel');
            setPropertyValue(this.Specification,'HighLevel',value);
        end
        function value=get.HighLevel(this)
            value=getPropertyValue(this.Specification,'HighLevel');
        end


        function set.MinPulseWidth(this,value)
            validateattributes(value,{'numeric'},...
            {'nonnegative','real','scalar','nonnan'},'','MinPulseWidth');
            setPropertyValue(this.Specification,'MinPulseWidth',value);
        end
        function value=get.MinPulseWidth(this)
            value=getPropertyValue(this.Specification,'MinPulseWidth');
        end


        function set.MaxPulseWidth(this,value)
            validateattributes(value,{'numeric'},...
            {'nonnegative','real','scalar','nonnan'},'','MaxPulseWidth');
            setPropertyValue(this.Specification,'MaxPulseWidth',value);
        end
        function value=get.MaxPulseWidth(this)
            value=getPropertyValue(this.Specification,'MaxPulseWidth');
        end


        function set.MinDuration(this,value)
            validateattributes(value,{'numeric'},...
            {'nonnegative','real','scalar','nonnan'},'','MinDuration');
            setPropertyValue(this.Specification,'MinDuration',value);
        end
        function value=get.MinDuration(this)
            value=getPropertyValue(this.Specification,'MinDuration');
        end


        function set.MaxDuration(this,value)
            validateattributes(value,{'numeric'},...
            {'nonnegative','real','scalar','nonnan'},'','MaxDuration');
            setPropertyValue(this.Specification,'MaxDuration',value);
        end
        function value=get.MaxDuration(this)
            value=getPropertyValue(this.Specification,'MaxDuration');
        end


        function set.Timeout(this,value)
            validateattributes(value,{'numeric'},...
            {'nonnegative','real','scalar','finite','nonnan'},'','Timeout');
            setPropertyValue(this.Specification,'Timeout',value);
        end
        function value=get.Timeout(this)
            value=getPropertyValue(this.Specification,'Timeout');
        end


        function set.Delay(this,value)
            validateattributes(value,{'numeric'},...
            {'real','scalar','finite','nonnan'},'','Timeout');
            setPropertyValue(this.Specification,'Delay',value);
        end
        function value=get.Delay(this)
            value=getPropertyValue(this.Specification,'Delay');
        end


        function set.Holdoff(this,value)
            validateattributes(value,{'numeric'},...
            {'nonnegative','real','scalar','finite','nonnan'},'','Holdoff');
            setPropertyValue(this.Specification,'Holdoff',value);
        end
        function value=get.Holdoff(this)
            value=getPropertyValue(this.Specification,'Holdoff');
        end


        function set.Channel(this,value)
            import dsp.webscopes.*;
            validateattributes(value,{'numeric'},...
            {'real','scalar','integer','finite','nonnan','>',0,'<=',this.getMaxNumChannels()},'','Channel');
            numChannels=this.getNumChannels();
            if this.isLocked()&&value>numChannels
                TimePlotBaseWebScope.localError('invalidTriggerChannelNumber',numChannels);
            end
            setPropertyValue(this.Specification,'Channel',value);
        end
        function value=get.Channel(this)
            value=getPropertyValue(this.Specification,'Channel');
        end
    end



    methods(Access=protected)

        function groups=getPropertyGroups(this)


            propList=getValidDisplayProperties(this.Specification,{...
            'Mode',...
            'Type',...
            'Polarity',...
            'AutoLevel',...
            'Position',...
            'Level',...
            'Hysteresis',...
            'LowLevel',...
            'HighLevel',...
            'MinPulseWidth',...
            'MaxPulseWidth',...
            'MinDuration',...
            'MaxDuration',...
            'Timeout',...
            'Delay',...
            'Holdoff',...
            'Channel',...
            'Enabled'});
            groups=matlab.mixin.util.PropertyGroup(propList);
        end

        function set=getPropertySet(this,propName)
            set=this.([propName,'Set']);

            if strcmpi(propName,'Polarity')
                if any(strcmpi(this.Type,{'pulse-width','runt'}))
                    set=this.PulseWidthAndRuntPolaritySet;
                elseif strcmpi(this.Type,'transition')
                    set=this.TransitionPolaritySet;
                elseif strcmpi(this.Type,'window')
                    set=this.WindowPolaritySet;
                end
            end
        end
    end
end