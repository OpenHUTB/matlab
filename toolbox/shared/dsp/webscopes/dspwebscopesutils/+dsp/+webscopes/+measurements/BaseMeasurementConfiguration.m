classdef(Abstract)BaseMeasurementConfiguration<handle&...
    matlab.mixin.CustomDisplay&...
    dsp.webscopes.mixin.PropertyValueValidator





    properties(AbortSet,Dependent)



        Enabled;
    end

    properties(Dependent,Hidden)

        ClientID;



        Enable;
    end

    properties(Transient,Hidden)

        Specification;
    end



    methods


        function set.Enabled(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','Enabled');
            setPropertyValue(this.Specification,'Enabled',logical(value));
        end
        function value=get.Enabled(this)
            value=getPropertyValue(this.Specification,'Enabled');
        end


        function set.ClientID(this,value)
            this.Specification.ClientID=value;
        end
        function value=get.ClientID(this)
            value=this.Specification.ClientID;
        end


        function set.Enable(this,value)
            this.Enabled=value;
        end
        function value=get.Enable(this)
            value=this.Enabled;
        end
    end



    methods(Hidden)
        function flag=isEnabled(this)
            flag=isEnabled(this.Specification);
        end
    end




    methods(Access=protected)

        function flag=isLocked(this)
            if~isempty(this.Specification.Specification)
                flag=this.Specification.Specification.isLocked();
            else
                flag=false;
            end
        end

        function n=getMaxNumChannels(this)
            n=this.Specification.Specification.MaxNumChannels;
        end

        function n=getNumChannels(this)
            n=this.Specification.Specification.getNumChannels();
        end

        function validatePropertiesOnSet(~,~)

        end

        function delete(~)


        end
    end
end
