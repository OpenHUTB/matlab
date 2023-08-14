



classdef DocBlockPropertySchema<Simulink.BlockPropertySchema
    properties(SetAccess=private)
        source='';
    end

    methods
        function this=DocBlockPropertySchema(h)
            this@Simulink.BlockPropertySchema(h)
            this.source=h;
        end

        function ret=setPropertyValues(obj,pairs,~)
            ret='';

            switch pairs{1}
            case 'content'
                userData=get_param(obj.source.Handle,'UserData');
                docblock('setContent',obj.source.Handle,pairs{2},userData.format);
            otherwise
                ret=setPropertyValues@Simulink.BlockPropertySchema(obj,pairs,false);
            end
        end
    end
end