classdef PropagationSpecification<comm.internal.linkBudgetApp.Specification




    properties
        RainRate=1;
        PolarizationTilt=35;
        FogCloudTemperature=10;
        FogCloudWaterDensity=0.4;
        Temperature=15;
        AtmPressure=101e3;
        WaterVaporDensity=4;
        OtherLosses=2;
    end

    methods
        function ids=getPropertyNames(~)
            ids={'RainRate','PolarizationTilt','FogCloudTemperature','FogCloudWaterDensity',...
            'Temperature','AtmPressure','WaterVaporDensity','OtherLosses'};
        end

        function set.RainRate(this,val)
            if this.validateProperty(val,{'numeric'},{'nonnegative'})
                this.RainRate=val;
            end
        end

        function set.PolarizationTilt(this,val)
            if this.validateProperty(val,{'numeric'},{})
                this.PolarizationTilt=val;
            end
        end

        function set.FogCloudTemperature(this,val)
            if this.validateProperty(val,{'numeric'},{'>=',-273})
                this.FogCloudTemperature=val;
            end
        end

        function set.FogCloudWaterDensity(this,val)
            if this.validateProperty(val,{'numeric'},{'nonnegative'})
                this.FogCloudWaterDensity=val;
            end
        end

        function set.Temperature(this,val)
            if this.validateProperty(val,{'numeric'},{'>=',-273})
                this.Temperature=val;
            end
        end

        function set.AtmPressure(this,val)
            if this.validateProperty(val,{'numeric'},{'positive'})
                this.AtmPressure=val;
            end
        end

        function set.WaterVaporDensity(this,val)
            if this.validateProperty(val,{'numeric'},{'nonnegative'})
                this.WaterVaporDensity=val;
            end
        end

        function set.OtherLosses(this,val)
            if this.validateProperty(val,{'numeric'},{'nonnegative'})
                this.OtherLosses=val;
            end
        end
    end
end


