classdef RxSpecification<comm.internal.linkBudgetApp.Specification




    properties
        Latitude=0;
        Longitude=0;
        Altitude=0;
        AntennaDiameter=1;
        AntennaEfficiency=55;
        RadomeLoss=2;
        FeederLoss=1;
        SystemTemperature=4200;
        OtherLosses=1;
    end

    methods
        function this=RxSpecification(varargin)
            for i=1:2:nargin
                this.(varargin{i})=varargin{i+1};
            end
        end

        function ids=getPropertyNames(~)
            ids={'Latitude','Longitude','Altitude','AntennaDiameter',...
            'AntennaEfficiency',...
            'RadomeLoss','FeederLoss','SystemTemperature','OtherLosses'};
        end

        function set.Latitude(this,val)
            if this.validateProperty(val,{'numeric'},{'>=',-90,'<=',90})
                this.Latitude=val;
            end
        end

        function set.Longitude(this,val)
            if this.validateProperty(val,{'numeric'},{'>=',-180,'<=',180})
                this.Longitude=val;
            end
        end

        function set.Altitude(this,val)
            if this.validateProperty(val,{'numeric'},{'nonnegative'})
                this.Altitude=val;
            end
        end

        function set.AntennaDiameter(this,val)
            if this.validateProperty(val,{'numeric'},{'nonnegative'})
                this.AntennaDiameter=val;
            end
        end

        function set.AntennaEfficiency(this,val)
            if this.validateProperty(val,{'numeric'},{'>=',0,'<=',100})
                this.AntennaEfficiency=val;
            end
        end

        function set.RadomeLoss(this,val)
            if this.validateProperty(val,{'numeric'},{'nonnegative'})
                this.RadomeLoss=val;
            end
        end

        function set.FeederLoss(this,val)
            if this.validateProperty(val,{'numeric'},{'nonnegative'})
                this.FeederLoss=val;
            end
        end

        function set.SystemTemperature(this,val)
            if this.validateProperty(val,{'numeric'},{'nonnegative'})
                this.SystemTemperature=val;
            end
        end

        function set.OtherLosses(this,val)
            if this.validateProperty(val,{'numeric'},{'nonnegative'})
                this.OtherLosses=val;
            end
        end

    end
end


