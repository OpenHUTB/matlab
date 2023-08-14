classdef TxSpecification<comm.internal.linkBudgetApp.Specification




    properties
        Latitude=0;
        Longitude=0;
        Altitude=0;
        AmplifierPower=10;
        AmplifierBackoffLoss=2;
        AntennaDiameter=2;
        AntennaEfficiency=55;
        FeederLoss=1;
        RadomeLoss=1;
        OtherLosses=2;
    end

    methods
        function this=TxSpecification(varargin)
            for i=1:2:nargin
                this.(varargin{i})=varargin{i+1};
            end
        end

        function ids=getPropertyNames(~)
            ids={'Latitude','Longitude','Altitude','AmplifierPower',...
            'AmplifierBackoffLoss','AntennaDiameter','AntennaEfficiency',...
            'FeederLoss','RadomeLoss','OtherLosses'};
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

        function set.AmplifierPower(this,val)
            if this.validateProperty(val,{'numeric'},{'nonnegative'})
                this.AmplifierPower=val;
            end
        end

        function set.AmplifierBackoffLoss(this,val)
            if this.validateProperty(val,{'numeric'},{'nonnegative'})
                this.AmplifierBackoffLoss=val;
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

        function set.FeederLoss(this,val)
            if this.validateProperty(val,{'numeric'},{'nonnegative'})
                this.FeederLoss=val;
            end
        end

        function set.RadomeLoss(this,val)
            if this.validateProperty(val,{'numeric'},{'nonnegative'})
                this.RadomeLoss=val;
            end
        end

        function set.OtherLosses(this,val)
            if this.validateProperty(val,{'numeric'},{'nonnegative'})
                this.OtherLosses=val;
            end
        end
    end
end


