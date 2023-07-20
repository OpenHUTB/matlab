classdef(Sealed=true)SecondOrderConeConstraint









    properties
        A(:,:){mustBeNumeric}=[]
        b(:,:){mustBeNumeric}=[]
        d(:,:){mustBeNumeric}=[]
        gamma(1,1){mustBeNumeric}=0
    end

    methods
        function obj=SecondOrderConeConstraint(A,b,d,gamma)



            if nargin==0
                return
            end
            narginchk(4,4);
            obj.A=A;
            obj.b=full(b(:));
            obj.d=d;
            obj.gamma=gamma;
        end
    end
end
