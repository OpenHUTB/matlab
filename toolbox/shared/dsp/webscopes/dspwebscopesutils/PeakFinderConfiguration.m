classdef PeakFinderConfiguration<dsp.webscopes.measurements.BaseMeasurementConfiguration



















    properties(AbortSet,Dependent)



        MinHeight;




        NumPeaks;



        MinDistance;




        Threshold;



        LabelPeaks;




        LabelFormat;
    end

    properties(Constant,Hidden)

        LabelFormatSet={'x + y','x','y'};
    end



    methods

        function this=PeakFinderConfiguration(hSpec)
            if nargin>0
                this.Specification=hSpec;
            else
                this.Specification=dsp.webscopes.measurements.PeakFinderSpecification;
            end
        end


        function set.NumPeaks(this,value)
            validateattributes(value,{'numeric'},...
            {'positive','real','scalar','integer','>=',1,'<=',99,'finite','nonnan'},'','NumPeaks');
            setPropertyValue(this.Specification,'NumPeaks',value);
        end
        function value=get.NumPeaks(this)
            value=getPropertyValue(this.Specification,'NumPeaks');
        end


        function set.MinHeight(this,value)
            validateattributes(value,{'numeric'},{'scalar','real'},'','MinHeight');
            setPropertyValue(this.Specification,'MinHeight',value);
        end
        function value=get.MinHeight(this)
            value=getPropertyValue(this.Specification,'MinHeight');
        end


        function set.MinDistance(this,value)
            validateattributes(value,{'numeric'},{'positive','real','scalar','nonnan'},'','MinDistance');
            if isfinite(value)
                validateattributes(value,{'numeric'},{'integer'},'','MinDistance');
            end
            setPropertyValue(this.Specification,'MinDistance',value);
        end
        function value=get.MinDistance(this)
            value=getPropertyValue(this.Specification,'MinDistance');
        end


        function set.Threshold(this,value)
            validateattributes(value,{'numeric'},{'nonnegative','real','scalar','nonnan'},'','Threshold');
            setPropertyValue(this.Specification,'Threshold',value);
        end
        function value=get.Threshold(this)
            value=getPropertyValue(this.Specification,'Threshold');
        end


        function set.LabelPeaks(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','LabelPeaks');
            setPropertyValue(this.Specification,'LabelPeaks',logical(value));
        end
        function value=get.LabelPeaks(this)
            value=getPropertyValue(this.Specification,'LabelPeaks');
        end


        function set.LabelFormat(this,value)
            value=validateEnum(this,'LabelFormat',value);
            setPropertyValue(this.Specification,'LabelFormat',value);
        end
        function value=get.LabelFormat(this)
            value=getPropertyValue(this.Specification,'LabelFormat');
        end
    end



    methods(Access=protected)

        function groups=getPropertyGroups(this)


            propList=getValidDisplayProperties(this.Specification,{'MinHeight',...
            'NumPeaks',...
            'MinDistance',...
            'Threshold',...
            'LabelPeaks',...
            'LabelFormat',...
            'Enabled'});
            groups=matlab.mixin.util.PropertyGroup(propList);
        end
    end
end