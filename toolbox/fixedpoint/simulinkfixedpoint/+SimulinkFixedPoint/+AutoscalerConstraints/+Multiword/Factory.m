classdef Factory<handle







    methods(Static)
        function multiword=getMultiword(wordLength)
            if isempty(wordLength)

                multiword=SimulinkFixedPoint.AutoscalerConstraints.Multiword.NoMultiword();
            else

                if~isempty(wordLength)&&(wordLength>0&&wordLength<=128)

                    multiword=SimulinkFixedPoint.AutoscalerConstraints.Multiword.HasMultiword(wordLength);
                else

                    error(message('SimulinkFixedPoint:autoscaling:WordlengthOutOfBounds'));
                end
            end
        end
    end
end


