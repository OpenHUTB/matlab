classdef(Sealed)OptimizationEquality<optim.problemdef.OptimizationConstraint






















    properties(Hidden,SetAccess=private,GetAccess=public)
        OptimizationEqualityVersion=1;
    end

    methods(Hidden)


        function equ=OptimizationEquality(varargin)

































            equ=equ@optim.problemdef.OptimizationConstraint(varargin{:});


            equ.Relation='==';

        end
    end



    methods(Hidden)
        c=upcast(equ)
        equ=downcast(equ)
    end


    methods(Hidden,Access=protected)

        newcon=createConstraint(~,varargin)
        checkConcat(~,~,con2cat)



    end


    methods(Hidden,Static)
        equ=empty(varargin)


        function cName=className()
            cName="OptimizationEquality";
        end



        function type=objectType()
            type="equality";
        end
    end
end