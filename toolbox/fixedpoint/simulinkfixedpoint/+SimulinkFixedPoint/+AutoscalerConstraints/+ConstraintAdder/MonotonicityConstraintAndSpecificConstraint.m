classdef MonotonicityConstraintAndSpecificConstraint<SimulinkFixedPoint.AutoscalerConstraints.ConstraintAdder.Interface







    methods(Access=protected)
        function constraint=addConstraintsInOrder(~,monotonicityConstraint,specificConstraint)

            constraint=copy(monotonicityConstraint);




            nConstraints=numel(constraint.ChildConstraint);
            validNodes=true(1,nConstraints);
            for iConstraint=1:nConstraints
                constraintSum=constraint.ChildConstraint(iConstraint)+specificConstraint;
                if constraintSum.allowsFixedPointProposals
                    setChildConstraint(constraint,constraintSum,iConstraint);
                else
                    validNodes(iConstraint)=false;
                end
            end

            removeChildConstraint(constraint,~validNodes);
            setSourceInfo(constraint,monotonicityConstraint.Object,monotonicityConstraint.ElementOfObject)


            if isempty(constraint.ChildConstraint)
                setSignedness(constraint,[]);
            else
                setSignedness(constraint,constraint.ChildConstraint(1).SpecificSigned);
            end
        end
    end
end


