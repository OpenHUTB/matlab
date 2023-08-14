classdef SignalStatisticsSpecification<dsp.webscopes.measurements.BaseMeasurementSpecification





    properties(AbortSet)
        ShowMax=true;
        ShowMin=true;
        ShowPeakToPeak=true;
        ShowMean=true;
        ShowVariance=false;
        ShowStandardDeviation=true;
        ShowMedian=true;
        ShowRMS=true;
        ShowMeanSquare=false;
    end



    methods


        function settings=getSettings(this)
            settings=getSettings@dsp.webscopes.measurements.BaseMeasurementSpecification(this);
            settings.ShowMax=this.ShowMax;
            settings.ShowMin=this.ShowMin;
            settings.ShowPeakToPeak=this.ShowPeakToPeak;
            settings.ShowMean=this.ShowMean;
            settings.ShowVariance=this.ShowVariance;
            settings.ShowStandardDeviation=this.ShowStandardDeviation;
            settings.ShowMedian=this.ShowMedian;
            settings.ShowRMS=this.ShowRMS;
            settings.ShowMeanSquare=this.ShowMeanSquare;
        end
    end



    methods(Hidden)

        function name=getMeasurementPropertyName(~)
            name='SignalStatistics';
        end

        function name=getMeasurementName(~)
            name='Signal Statistics';
        end
    end
end