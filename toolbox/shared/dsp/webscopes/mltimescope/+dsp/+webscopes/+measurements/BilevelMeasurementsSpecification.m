classdef BilevelMeasurementsSpecification<dsp.webscopes.measurements.BaseMeasurementSpecification





    properties(AbortSet)
        AutoStateLevel=true;
        HighStateLevel=2.3;
        LowStateLevel=0;
        StateLevelTolerance=2;
        UpperReferenceLevel=90.0;
        MidReferenceLevel=50.0;
        LowerReferenceLevel=10.0;
        SettleSeek=0.02;
        ShowTransitions=false;
        ShowAberrations=false;
        ShowCycles=false;
    end



    methods


        function settings=getSettings(this)
            settings=getSettings@dsp.webscopes.measurements.BaseMeasurementSpecification(this);
            settings.AutoStateLevel=this.AutoStateLevel;
            settings.HighStateLevel=this.HighStateLevel;
            settings.LowStateLevel=this.LowStateLevel;
            settings.StateLevelTolerance=this.StateLevelTolerance;
            settings.UpperReferenceLevel=this.UpperReferenceLevel;
            settings.MidReferenceLevel=this.MidReferenceLevel;
            settings.LowerReferenceLevel=this.LowerReferenceLevel;
            settings.SettleSeek=this.SettleSeek;
            settings.ShowTransitions=this.ShowTransitions;
            settings.ShowAberrations=this.ShowAberrations;
            settings.ShowCycles=this.ShowCycles;
        end

        function flag=isInactiveProperty(this,propName)
            flag=false;
            switch propName
            case{'HighStateLevel','LowStateLevel'}
                flag=this.AutoStateLevel;
            case 'Enabled'
                flag=true;
            end
        end

        function flag=isEnabled(this)
            flag=this.ShowTransitions||this.ShowAberrations||this.ShowCycles;
        end
    end



    methods(Hidden)

        function name=getMeasurementPropertyName(~)
            name='BilevelMeasurements';
        end

        function name=getMeasurementName(~)
            name='Bilevel Measurements';
        end
    end
end