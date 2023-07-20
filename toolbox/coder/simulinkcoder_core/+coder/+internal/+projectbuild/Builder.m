classdef(Abstract,Hidden)Builder<handle




    properties(GetAccess=protected,SetAccess=immutable)
        Model;
    end

    properties(Access=protected)
        CleanupStack={};
    end

    methods(Access=protected)


        function this=Builder(model)
            this.Model=model;
        end
    end

    methods


        build(this);

        function delete(this)

            cellfun(@(fh)fh(),this.CleanupStack(end:-1:1))
        end
    end
end
