classdef PeakFinderSpecification<dsp.webscopes.measurements.BaseMeasurementSpecification





    properties(AbortSet)
        NumPeaks=3;
        MinHeight=-Inf;
        MinDistance=1;
        Threshold=0;
        LabelPeaks=false;
        LabelFormat='x + y';
    end



    methods

        function propValue=preprocessPropertyValue(~,propName,value)
            propValue=value;
            if any(strcmpi(propName,{'MinHeight','MinDistance','Threshold'}))
                propValue=string(value);
            end
        end


        function settings=getSettings(this)
            settings=getSettings@dsp.webscopes.measurements.BaseMeasurementSpecification(this);
            settings.NumPeaks=this.NumPeaks;
            settings.MinHeight=string(this.MinHeight);
            settings.MinDistance=string(this.MinDistance);
            settings.Threshold=string(this.Threshold);
            settings.LabelPeaks=this.LabelPeaks;
            settings.LabelFormat=this.LabelFormat;
        end


        function S=toStruct(this)
            S=getSettings(this);
            S.MinHeight=double(this.MinHeight);
            S.MinDistance=double(this.MinDistance);
            S.Threshold=double(this.Threshold);
        end
    end



    methods(Hidden)

        function name=getMeasurementPropertyName(~)
            name='PeakFinder';
        end

        function name=getMeasurementName(~)
            name='Peak Finder';
        end
    end
end