classdef MinimumToleranceCalculator<handle





    methods(Access={?FunctionApproximation.internal.AbstractUtils})
        function this=MinimumToleranceCalculator()
        end
    end

    methods
        function tolerance=getTolerance(~,dataType)
            if dataType.isfixed||dataType.isboolean

                tolerance=double(dataType.Slope);
            else


                if dataType.issingle

                    tolerance=double(realmin('single'));
                elseif dataType.isdouble

                    tolerance=realmin('double');
                elseif dataType.ishalf

                    tolerance=double(half.realmin);

                end
            end
        end
    end
end
