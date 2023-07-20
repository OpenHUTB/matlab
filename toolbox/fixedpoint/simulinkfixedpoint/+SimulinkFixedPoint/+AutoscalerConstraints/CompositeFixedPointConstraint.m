classdef(Abstract)CompositeFixedPointConstraint<SimulinkFixedPoint.AutoscalerConstraints.FixedPointConstraint








    properties(SetAccess=protected)

        ChildConstraint=[];
    end

    methods
        function setSourceInfo(this,object,elementOfObject)






            this.Object=object;
            this.ElementOfObject=elementOfObject;
            nConstraints=numel(this.ChildConstraint);
            for iConstraint=1:nConstraints
                setSourceInfo(this.ChildConstraint(iConstraint),object,elementOfObject)
            end
        end
    end

    methods(Hidden)
        function setChildConstraint(this,constraint,index)


            if isempty(constraint)

                this.ChildConstraint(index)=[];
            else

                this.ChildConstraint(index)=constraint;
            end
        end

        function removeChildConstraint(this,index)

            setChildConstraint(this,[],index);
        end
    end
end


