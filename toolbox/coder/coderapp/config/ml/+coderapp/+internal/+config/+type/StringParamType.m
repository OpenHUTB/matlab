classdef(Sealed)StringParamType<coderapp.internal.config.type.AbstractStringParamType



    methods
        function this=StringParamType()
            this@coderapp.internal.config.type.AbstractStringParamType('string',...
            'coderapp.internal.config.data.StringParamData');
        end
    end

    methods
        function adjusted=validate(this,value,dataObj)
            adjusted=this.validateString(value,dataObj);
        end
    end

    methods(Access=protected)
        function imported=importValue(this,value)
            imported=this.validateString(value);
        end

        function value=exportValue(~,value)
        end

        function imported=valueFromSchema(this,value)
            imported=this.validateString(value);
        end
    end
end

