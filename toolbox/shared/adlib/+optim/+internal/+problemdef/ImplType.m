classdef(Enumeration)ImplType<uint8










    enumeration
        Numeric(0)
        Linear((intmax('uint8')-1)/2)
        Quadratic(intmax('uint8')-1)
        Nonlinear(intmax('uint8'))
    end

    methods
        function obj=ImplType(inInt)
            obj@uint8(inInt);
        end
    end

    methods(Static)


        function out=typePlusMinus(type1,type2)
            out=optim.internal.problemdef.ImplType(max(type1,type2));
        end


        function out=typeDivide(type1,type2)
            out=optim.internal.problemdef.ImplType(type1+intmax('uint8')*type2);
        end


        function out=typeTimes(type1,type2)
            out=optim.internal.problemdef.ImplType(type1+type2);
        end


        function out=typeSubsasgn(types)
            out=optim.internal.problemdef.ImplType(max(types));
        end
    end

end

