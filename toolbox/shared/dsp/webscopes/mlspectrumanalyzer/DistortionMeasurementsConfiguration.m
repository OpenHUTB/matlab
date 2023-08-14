classdef DistortionMeasurementsConfiguration<dsp.webscopes.measurements.BaseMeasurementConfiguration



































    properties(Dependent)



        Type;





        NumHarmonics;



        LabelValues;
    end

    properties(Dependent,Hidden)



        Algorithm;
    end

    properties(Constant,Hidden)

        TypeSet={'harmonic','intermodulation'};
    end




    methods

        function this=DistortionMeasurementsConfiguration(hSpec)
            if nargin>0
                this.Specification=hSpec;
            else
                this.Specification=dsp.webscopes.measurements.DistortionMeasurementsSpecification;
            end
        end


        function set.Type(this,value)
            value=validateEnum(this,'Type',value);
            setPropertyValue(this.Specification,'Type',value);
        end
        function value=get.Type(this)
            value=getPropertyValue(this.Specification,'Type');
        end


        function set.NumHarmonics(this,value)
            validateattributes(value,{'numeric'},...
            {'positive','real','scalar','integer','>=',1,'<=',99,'finite','nonnan'},'','NumHarmonics');
            setPropertyValue(this.Specification,'NumHarmonics',value);
        end
        function value=get.NumHarmonics(this)
            value=getPropertyValue(this.Specification,'NumHarmonics');
        end


        function set.LabelValues(this,value)
            validateattributes(value,{'logical'},{'scalar'},'','LabelValues');
            setPropertyValue(this.Specification,'LabelValues',value);
        end
        function value=get.LabelValues(this)
            value=getPropertyValue(this.Specification,'LabelValues');
        end


        function set.Algorithm(this,value)
            this.Type=value;
        end
        function value=get.Algorithm(this)
            value=this.Type;
        end
    end



    methods(Access=protected)

        function groups=getPropertyGroups(this)


            propList=getValidDisplayProperties(this.Specification,{...
            'Type',...
            'NumHarmonics',...
            'LabelValues',...
            'Enabled'});
            groups=matlab.mixin.util.PropertyGroup(propList);
        end
    end
end