classdef FixitActions








    methods(Access=public,Static)
        function disableDecimationOnSignal(portIdx,blockPath)



            hLineForOutport=coder.internal.xcp.FixitActions.getLineHandle(portIdx,blockPath);
            set(hLineForOutport,'DataLoggingDecimateData',false);
        end

        function disableLimitDataPointsOnSignal(portIdx,blockPath)



            hLineForOutport=coder.internal.xcp.FixitActions.getLineHandle(portIdx,blockPath);
            set(hLineForOutport,'DataLoggingLimitDataPoints',false);
        end
    end

    methods(Access=private,Static)
        function hLineForOutport=getLineHandle(portIdx,blockPath)



            hLines=get_param(blockPath,'LineHandles');
            hLineForOutport=hLines.Outport(portIdx);
        end
    end
end