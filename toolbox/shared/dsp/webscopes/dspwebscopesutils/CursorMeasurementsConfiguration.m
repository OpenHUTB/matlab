classdef CursorMeasurementsConfiguration<dsp.webscopes.measurements.BaseMeasurementConfiguration















    properties(AbortSet,Dependent)




        XLocation;



        SnapToData;



        LockSpacing;
    end



    methods

        function this=CursorMeasurementsConfiguration(hSpec)
            if nargin>0
                this.Specification=hSpec;
            else
                this.Specification=dsp.webscopes.measurements.CursorMeasurementsSpecification;
            end
        end


        function set.XLocation(this,value)
            validateattributes(value,{'numeric'},...
            {'real','vector','numel',2},'','XLocation');
            setPropertyValue(this.Specification,'XLocation',value);
        end
        function value=get.XLocation(this)
            value=getPropertyValue(this.Specification,'XLocation');
        end


        function set.SnapToData(this,value)
            validateattributes(value,{'logical'},{'scalar'},'','SnapToData');
            setPropertyValue(this.Specification,'SnapToData',value);
        end
        function value=get.SnapToData(this)
            value=getPropertyValue(this.Specification,'SnapToData');
        end


        function set.LockSpacing(this,value)
            validateattributes(value,{'logical'},{'scalar'},'','LockSpacing');
            setPropertyValue(this.Specification,'LockSpacing',value);
        end
        function value=get.LockSpacing(this)
            value=getPropertyValue(this.Specification,'LockSpacing');
        end
    end



    methods(Access=protected)

        function groups=getPropertyGroups(this)


            propList=getValidDisplayProperties(this.Specification,{...
            'XLocation',...
            'SnapToData',...
            'LockSpacing',...
            'Enabled'});
            groups=matlab.mixin.util.PropertyGroup(propList);
        end
    end
end