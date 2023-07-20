classdef VectorStreamUtils<handle





    methods(Static=true)
        function[totalDataWidth,totalElementWidth,totalPortDimension]=getPackedDataWidth(elementWidth,portDimension,isComplex,PackingMode,isFrameMode)





















            if nargin<5
                isFrameMode=false;
            end
            if strcmp(PackingMode,'Power of 2 Aligned')
                totalElementWidth=2^(nextpow2(elementWidth));
            elseif strcmp(PackingMode,'Bit Aligned')
                totalElementWidth=elementWidth;
            else
                totalElementWidth=elementWidth;
            end

            if(isFrameMode)
                totalPortDimension=1;
            else
                totalPortDimension=portDimension;
            end


            if isComplex
                totalPortDimension=2*totalPortDimension;
            end


            dataWidth=totalElementWidth*totalPortDimension;


            totalDataWidth=max(8,8*ceil(dataWidth/8));
        end
    end
end