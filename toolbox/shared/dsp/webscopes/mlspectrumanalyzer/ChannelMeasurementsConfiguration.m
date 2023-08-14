classdef ChannelMeasurementsConfiguration<dsp.webscopes.measurements.BaseMeasurementConfiguration


















































    properties(Dependent)



        Type;





        FrequencySpan;






        Span;






        CenterFrequency;







        StartFrequency;







        StopFrequency;






        PercentOccupiedBW;




        AdjacentBW;




        FilterShape;





        FilterCoeff;




        NumOffsets;







        ACPROffsets;
    end

    properties(Dependent,Hidden)



        Algorithm;
    end

    properties(Constant,Hidden)

        TypeSet={'occupied-bandwidth','acpr'};
        TypeObsoleteSet={'Occupied BW','ACPR'};
        FrequencySpanSet={'span-and-center-frequency','start-and-stop-frequencies'};
        FrequencySpanObsoleteSet={'Span and center frequency','Start and stop frequency'};
        FilterShapeSet={'none','gaussian','rrc'};
    end



    methods

        function this=ChannelMeasurementsConfiguration(hSpec)
            if nargin>0
                this.Specification=hSpec;
            else
                this.Specification=dsp.webscopes.measurements.ChannelMeasurementsSpecification;
            end
        end


        function set.Type(this,value)
            value=validateEnum(this,'Type',value);
            setPropertyValue(this.Specification,'Type',value);
        end
        function value=get.Type(this)
            value=getPropertyValue(this.Specification,'Type');
        end


        function set.FrequencySpan(this,value)
            value=validateEnum(this,'FrequencySpan',value);
            setPropertyValue(this.Specification,'FrequencySpan',value);
        end
        function value=get.FrequencySpan(this)
            value=getPropertyValue(this.Specification,'FrequencySpan');
        end


        function set.Span(this,value)
            validateattributes(value,{'numeric'},...
            {'positive','real','scalar','finite','nonnan'},'','Span');
            setPropertyValue(this.Specification,'Span',value);
        end
        function value=get.Span(this)
            value=getPropertyValue(this.Specification,'Span');
        end


        function set.CenterFrequency(this,value)
            validateattributes(value,{'numeric'},...
            {'real','scalar','finite','nonnan'},'','CenterFrequency');
            setPropertyValue(this.Specification,'CenterFrequency',value);
        end
        function value=get.CenterFrequency(this)
            value=getPropertyValue(this.Specification,'CenterFrequency');
        end


        function set.StartFrequency(this,value)
            validateattributes(value,{'numeric'},...
            {'real','scalar','finite','nonnan'},'','StartFrequency');
            setPropertyValue(this.Specification,'StartFrequency',value);
        end
        function value=get.StartFrequency(this)
            value=getPropertyValue(this.Specification,'StartFrequency');
        end


        function set.StopFrequency(this,value)
            validateattributes(value,{'numeric'},...
            {'real','scalar','finite','nonnan'},'','StopFrequency');
            setPropertyValue(this.Specification,'StopFrequency',value);
        end
        function value=get.StopFrequency(this)
            value=getPropertyValue(this.Specification,'StopFrequency');
        end


        function set.PercentOccupiedBW(this,value)
            validateattributes(value,{'numeric'},...
            {'positive','real','scalar','>=',1,'<',100,'finite','nonnan'},'','PercentOccupiedBW');
            setPropertyValue(this.Specification,'PercentOccupiedBW',value);
        end
        function value=get.PercentOccupiedBW(this)
            value=getPropertyValue(this.Specification,'PercentOccupiedBW');
        end


        function set.AdjacentBW(this,value)
            validateattributes(value,{'numeric'},...
            {'real','scalar','positive'},'','AdjacentBW');
            setPropertyValue(this.Specification,'AdjacentBW',value);
        end
        function value=get.AdjacentBW(this)
            value=getPropertyValue(this.Specification,'AdjacentBW');
        end


        function set.FilterShape(this,value)
            value=validateEnum(this,'FilterShape',value);
            setPropertyValue(this.Specification,'FilterShape',value);
        end
        function value=get.FilterShape(this)
            value=getPropertyValue(this.Specification,'FilterShape');
        end


        function set.FilterCoeff(this,value)
            validateattributes(value,{'numeric'},...
            {'real','scalar','>=',0,'<=',1,'finite','nonnan'},'','FilterCoeff');
            setPropertyValue(this.Specification,'FilterCoeff',value);
        end
        function value=get.FilterCoeff(this)
            value=getPropertyValue(this.Specification,'FilterCoeff');
        end


        function set.NumOffsets(this,value)
            validateattributes(value,{'numeric'},...
            {'positive','real','scalar','integer','>=',1,'<=',12,'finite','nonnan'},'','NumOffsets');
            setPropertyValue(this.Specification,'NumOffsets',value);
        end
        function value=get.NumOffsets(this)
            value=getPropertyValue(this.Specification,'NumOffsets');
        end


        function set.ACPROffsets(this,value)
            validateattributes(value,{'numeric'},...
            {'real','vector'},'','ACPROffsets');
            setPropertyValue(this.Specification,'ACPROffsets',value);
        end
        function value=get.ACPROffsets(this)
            value=getPropertyValue(this.Specification,'ACPROffsets');
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
            'FrequencySpan',...
            'Span',...
            'CenterFrequency',...
            'StartFrequency',...
            'StopFrequency',...
            'PercentOccupiedBW',...
            'AdjacentBW',...
            'FilterShape',...
            'FilterCoeff',...
            'NumOffsets',...
            'ACPROffsets',...
            'Enabled'});
            groups=matlab.mixin.util.PropertyGroup(propList);
        end
    end
end