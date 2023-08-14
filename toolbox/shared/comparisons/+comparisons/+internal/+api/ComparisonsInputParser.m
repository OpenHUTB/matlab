classdef(Abstract,Hidden)ComparisonsInputParser<handle






    methods(Abstract,Access=public)

        result=parse(this,varargin);

    end

    methods(Access=protected)

        function validateStringArgument(this,argument,name)
            validateattributes(...
            this.preprocessIfString(argument),...
            {'char','string'},...
            {'scalartext','nonempty'},...
name...
            );
        end

        function name=preprocessIfString(~,name)
            if~isa(name,'string')
                return;
            end

            if any(size(name)>1)
                return;
            end

            name=char(name);
        end

    end

end