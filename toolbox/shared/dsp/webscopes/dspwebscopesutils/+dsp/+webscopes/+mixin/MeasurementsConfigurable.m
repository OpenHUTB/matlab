classdef MeasurementsConfigurable<handle





    properties





        CursorMeasurements;






        PeakFinder;






        SignalStatistics;
    end



    methods

        function set.CursorMeasurements(this,value)
            import dsp.webscopes.internal.*;
            if this.isMeasurementSupported('cursors')
                if isa(value,'CursorMeasurementsConfiguration')&&isvalid(value)
                    if isempty(this.CursorMeasurements)
                        this.CursorMeasurements=value;
                    else
                        set(this.CursorMeasurements,get(value));
                    end
                else
                    BaseWebScope.localError('invalidMeasurementConfigurationObject','CursorMeasurements','CursorMeasurementsConfiguration');
                end
            end
        end

        function set.PeakFinder(this,value)
            import dsp.webscopes.internal.*;
            if this.isMeasurementSupported('peaks')
                if isa(value,'PeakFinderConfiguration')&&isvalid(value)
                    if isempty(this.PeakFinder)
                        this.PeakFinder=value;
                    else
                        set(this.PeakFinder,get(value));
                    end
                else
                    BaseWebScope.localError('invalidMeasurementConfigurationObject','PeakFinder','PeakFinderConfiguration');
                end
            end
        end

        function set.SignalStatistics(this,value)
            import dsp.webscopes.internal.*;
            if this.isMeasurementSupported('stats')
                if isa(value,'SignalStatisticsConfiguration')&&isvalid(value)
                    if isempty(this.SignalStatistics)
                        this.SignalStatistics=value;
                    else
                        set(this.SignalStatistics,get(value));
                    end
                else
                    BaseWebScope.localError('invalidMeasurementConfigurationObject','SignalStatistics','SignalStatisticsConfiguration');
                end
            end
        end
    end



    methods(Access=protected)

        function addMeasurementsConfiguration(this)
            if isMeasurementSupported(this,'peaks')
                this.PeakFinder=getMeasurementConfiguration(this,'peaks');
            end
            if isMeasurementSupported(this,'cursors')
                this.CursorMeasurements=getMeasurementConfiguration(this,'cursors');
            end
            if isMeasurementSupported(this,'stats')
                this.SignalStatistics=getMeasurementConfiguration(this,'stats');
            end
        end

        function config=getMeasurementConfiguration(this,measurer)
            switch(measurer)
            case 'cursors'
                if isempty(this.CursorMeasurements)
                    config=CursorMeasurementsConfiguration(this.Specification.CursorMeasurements);
                else
                    config=this.CursorMeasurements;
                end

                this.Specification.CursorMeasurements.Configuration=config;
            case 'peaks'
                if isempty(this.PeakFinder)
                    config=PeakFinderConfiguration(this.Specification.PeakFinder);
                else
                    config=this.PeakFinder;
                end

                this.Specification.PeakFinder.Configuration=config;
            case 'stats'
                if isempty(this.SignalStatistics)
                    config=SignalStatisticsConfiguration(this.Specification.SignalStatistics);
                else
                    config=this.SignalStatistics;
                end

                this.Specification.SignalStatistics.Configuration=config;
            end
        end


        function flag=isMeasurementSupported(this,measurer)
            flag=isMeasurementSupported(this.Specification,measurer);
        end
    end
end