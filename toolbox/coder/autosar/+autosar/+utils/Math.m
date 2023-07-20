classdef Math<handle




    methods(Static,Access=public)
        function[closedLowerLimit,closedUpperLimit]=toLowerAndUpperLimit(isSigned,wordSize)

            closedUpperLimit=(2^(wordSize-isSigned)-1);
            if(isSigned)
                closedLowerLimit=-2^(wordSize-1);
            else
                closedLowerLimit=0;
            end
        end

        function isPow2=isPow2(in)
            [F,~]=log2(in);
            isPow2=(F==0.5);
        end
    end
end
