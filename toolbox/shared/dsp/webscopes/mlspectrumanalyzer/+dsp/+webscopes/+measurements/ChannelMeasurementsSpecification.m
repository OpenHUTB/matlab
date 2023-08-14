classdef ChannelMeasurementsSpecification<dsp.webscopes.measurements.BaseMeasurementSpecification






    properties(AbortSet)
        Type='occupied-bandwidth';
        FrequencySpan='span-and-center-frequency';
        Span=2000;
        CenterFrequency=0;
        StartFrequency=-1000;
        StopFrequency=1000;
        PercentOccupiedBW=99;
        AdjacentBW=1000;
        NumOffsets=2;
        ACPROffsets=[2000,3500];
        FilterShape='none';
        FilterCoeff=0.5;
    end



    methods


        function settings=getSettings(this)
            settings=getSettings@dsp.webscopes.measurements.BaseMeasurementSpecification(this);
            settings.Type=this.Type;
            settings.FrequencySpan=this.FrequencySpan;
            settings.Span=this.Span;
            settings.CenterFrequency=this.CenterFrequency;
            settings.StartFrequency=this.StartFrequency;
            settings.StopFrequency=this.StopFrequency;
            settings.PercentOccupiedBW=this.PercentOccupiedBW;
            settings.AdjacentBW=this.AdjacentBW;
            settings.NumOffsets=this.NumOffsets;
            settings.ACPROffsets=this.ACPROffsets;
            settings.FilterShape=this.FilterShape;
            settings.FilterCoeff=this.FilterCoeff;
        end

        function flag=isInactiveProperty(this,propName)
            flag=false;
            switch propName
            case{'Span','CenterFrequency'}
                flag=~strcmpi(this.FrequencySpan,'span-and-center-frequency');
            case{'StartFrequency','StopFrequency'}
                flag=strcmpi(this.FrequencySpan,'span-and-center-frequency');
            case 'PercentOccupiedBW'
                flag=~strcmpi(this.Type,'occupied-bandwidth');
            case{'NumOffsets','AdjacentBW','FilterShape','ACPROffsets'}
                flag=strcmpi(this.Type,'occupied-bandwidth');
            case 'FilterCoeff'
                flag=strcmpi(this.Type,'occupied-bandwidth')||strcmpi(this.FilterShape,'none');
            end
        end
    end



    methods(Hidden)

        function name=getMeasurementPropertyName(~)
            name='ChannelMeasurements';
        end

        function name=getMeasurementName(~)
            name='Channel Measurements';
        end
    end
end