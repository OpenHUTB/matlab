classdef Factory<handle






    methods
        function adder=getAdder(~,constraint1,constraint2)
            if allowsFixedPointProposals(constraint1)&&allowsFixedPointProposals(constraint2)



                addOrder=getAddOrder(constraint1.Index,constraint2.Index);
                if addOrder==SimulinkFixedPoint.AutoscalerConstraints.ConstraintAdder.AddOrder.SwapOrder
                    adderClass=[char(constraint2.Index),'And',char(constraint1.Index)];
                else
                    adderClass=[char(constraint1.Index),'And',char(constraint2.Index)];
                end


                adder=SimulinkFixedPoint.AutoscalerConstraints.ConstraintAdder.(adderClass);
            else

                adder=SimulinkFixedPoint.AutoscalerConstraints.ConstraintAdder.Default;

                addOrder=SimulinkFixedPoint.AutoscalerConstraints.ConstraintAdder.AddOrder.InOrder;
            end


            setAddOrder(adder,addOrder);
        end
    end
end


