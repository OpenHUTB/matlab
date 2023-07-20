classdef TrueFalse




    enumeration
true
false
    end

    methods(Static)
        function tf=create(val)


            if isscalar(val)&&islogical(val)
                if val
                    tf=matlab.system.internal.TrueFalse.true;
                else
                    tf=matlab.system.internal.TrueFalse.false;
                end
            else
                tf=val;
            end
        end
    end
end
