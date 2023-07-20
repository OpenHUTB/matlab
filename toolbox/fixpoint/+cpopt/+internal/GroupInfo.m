classdef GroupInfo<handle










    properties
Proposable
TypeKnown
SlopeAdjustmentFactor
Bias
Complex
ID
    end

    methods
        function obj=GroupInfo(name,active)
            obj.ID=name;
            obj.Proposable=active;
            obj.TypeKnown=false;
            obj.Complex=false;
        end

        function known=isKnown(obj)
            known=obj.TypeKnown;
        end

        function proposable=isProposable(obj)
            proposable=obj.Proposable;
        end

        function setComplex(obj)
            obj.Complex=true;
            obj.setType(1,0);
        end

        function setType(obj,saf,bias)
            obj.Bias=bias;
            obj.SlopeAdjustmentFactor=saf;


            obj.TypeKnown=~isempty(obj.Bias)||~isempty(obj.SlopeAdjustmentFactor);
        end
    end
end
