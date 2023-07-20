classdef NoMultiword<SimulinkFixedPoint.AutoscalerConstraints.Multiword.Interface







    methods(Access=?SimulinkFixedPoint.AutoscalerConstraints.Multiword.Factory)
        function this=NoMultiword()

        end
    end
    methods
        function multiwordSum=plus(this,other)
            if isempty(other.WordLength)
                multiwordSum=this;
            else
                multiwordSum=other;
            end
        end
        function flag=isLesserThan(~,~)
            flag=false;
        end
    end
end
