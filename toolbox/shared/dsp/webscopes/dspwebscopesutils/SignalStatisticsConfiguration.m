classdef SignalStatisticsConfiguration<dsp.webscopes.measurements.BaseMeasurementConfiguration




















    properties(AbortSet,Dependent)



        ShowMax;



        ShowMin;




        ShowPeakToPeak;



        ShowMean;




        ShowVariance;





        ShowStandardDeviation;



        ShowMedian;



        ShowRMS;




        ShowMeanSquare;
    end



    methods

        function this=SignalStatisticsConfiguration(hSpec)
            if nargin>0
                this.Specification=hSpec;
            else
                this.Specification=dsp.webscopes.measurements.SignalStatisticsSpecification;
            end
        end


        function set.ShowMax(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','ShowMax');
            setPropertyValue(this.Specification,'ShowMax',logical(value));
        end
        function value=get.ShowMax(this)
            value=getPropertyValue(this.Specification,'ShowMax');
        end


        function set.ShowMin(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','ShowMin');
            setPropertyValue(this.Specification,'ShowMin',logical(value));
        end
        function value=get.ShowMin(this)
            value=getPropertyValue(this.Specification,'ShowMin');
        end


        function set.ShowPeakToPeak(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','ShowPeakToPeak');
            setPropertyValue(this.Specification,'ShowPeakToPeak',logical(value));
        end
        function value=get.ShowPeakToPeak(this)
            value=getPropertyValue(this.Specification,'ShowPeakToPeak');
        end


        function set.ShowMean(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','ShowMean');
            setPropertyValue(this.Specification,'ShowMean',logical(value));
        end
        function value=get.ShowMean(this)
            value=getPropertyValue(this.Specification,'ShowMean');
        end


        function set.ShowVariance(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','ShowVariance');
            setPropertyValue(this.Specification,'ShowVariance',logical(value));
        end
        function value=get.ShowVariance(this)
            value=getPropertyValue(this.Specification,'ShowVariance');
        end


        function set.ShowStandardDeviation(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','ShowStandardDeviation');
            setPropertyValue(this.Specification,'ShowStandardDeviation',logical(value));
        end
        function value=get.ShowStandardDeviation(this)
            value=getPropertyValue(this.Specification,'ShowStandardDeviation');
        end


        function set.ShowMedian(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','ShowMedian');
            setPropertyValue(this.Specification,'ShowMedian',logical(value));
        end
        function value=get.ShowMedian(this)
            value=getPropertyValue(this.Specification,'ShowMedian');
        end


        function set.ShowRMS(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','ShowRMS');
            setPropertyValue(this.Specification,'ShowRMS',logical(value));
        end
        function value=get.ShowRMS(this)
            value=getPropertyValue(this.Specification,'ShowRMS');
        end


        function set.ShowMeanSquare(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','ShowMeanSquare');
            setPropertyValue(this.Specification,'ShowMeanSquare',logical(value));
        end
        function value=get.ShowMeanSquare(this)
            value=getPropertyValue(this.Specification,'ShowMeanSquare');
        end
    end



    methods(Access=protected)

        function groups=getPropertyGroups(this)


            propList=getValidDisplayProperties(this.Specification,{'ShowMax',...
            'ShowMin',...
            'ShowPeakToPeak',...
            'ShowMean',...
            'ShowVariance',...
            'ShowStandardDeviation',...
            'ShowMedian',...
            'ShowRMS',...
            'ShowMeanSquare',...
            'Enabled'});
            groups=matlab.mixin.util.PropertyGroup(propList);
        end
    end
end