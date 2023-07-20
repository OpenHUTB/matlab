classdef Verify<handle

    methods(Static)

        function ScalarCharOrString(val)
            if(~isa(val,'char')&&~isa(val,'string'))||(numel(string(val))>1)
                error(message('dashboard:uidatamodel:ScalarCharOrString'));
            end
        end

        function LogicalOrDoubleOneZero(val)
            if~islogical(val)
                if~isnumeric(val)||(numel(val)>1)||isempty(val)...
                    ||((val~=0)&&(val~=1))
                    error(message('dashboard:uidatamodel:BoolOrZeroOne'));
                end
            end
        end

    end

end
