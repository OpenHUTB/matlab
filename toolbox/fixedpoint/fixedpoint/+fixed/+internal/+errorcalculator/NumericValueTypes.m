classdef NumericValueTypes<handle






    properties(SetAccess=protected)
Infs
NaNs
Size
    end

    properties(Dependent)
Finites
    end

    methods
        function this=NumericValueTypes(value)
            this.Size=size(value);
            this.NaNs=isnan(value);
            this.Infs=isinf(value);
        end

        function finites=get.Finites(this)
            finites=~(this.NaNs|this.Infs);
        end
    end
end


