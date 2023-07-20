classdef DerivativeStrategy<handle









    properties
        Order;
        FiniteDifference;
        StepSize;
    end

    methods
        function obj=DerivativeStrategy(order,finiteDifference,stepSize)

            obj.Order=order;



            obj.FiniteDifference=finiteDifference;




            obj.StepSize=stepSize;
        end
    end
end


