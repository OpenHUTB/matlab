classdef LinkSpecification<comm.internal.linkBudgetApp.Specification




    properties
        Frequency=14e9;
        Bandwidth=6e6;
        Polarization=45;
        BitRate=10;
        ImplementationLoss=2;
        RequiredEbN0=7;
    end

    properties(SetAccess=protected,Hidden)
wavelength
    end

    methods
        function ids=getPropertyNames(~)
            ids={'Frequency','Bandwidth','Polarization','BitRate',...
            'ImplementationLoss','RequiredEbN0'};
        end

        function setWavelength(this,val)
            this.wavelength=val;
        end

        function val=getWavelength(this)
            val=this.wavelength;
        end

        function set.Frequency(this,val)
            if this.validateProperty(val,{'numeric'},{'positive'})
                this.Frequency=val;
            end
        end

        function set.Bandwidth(this,val)
            if this.validateProperty(val,{'numeric'},{'positive'})
                this.Bandwidth=val;
            end
        end

        function set.Polarization(this,val)
            if this.validateProperty(val,{'numeric'},{'>=',0,'<=',180})
                this.Polarization=val;
            end
        end

        function set.BitRate(this,val)
            if this.validateProperty(val,{'numeric'},{'positive'})
                this.BitRate=val;
            end
        end

        function set.ImplementationLoss(this,val)
            if this.validateProperty(val,{'numeric'},{'nonnegative'})
                this.ImplementationLoss=val;
            end
        end

        function set.RequiredEbN0(this,val)
            if this.validateProperty(val,{'numeric'},{})
                this.RequiredEbN0=val;
            end
        end

    end


end


