function setupSegmentBuffer(obj)









    if obj.pIsDownSamplerEnabled




        obj.sSegmentBuffer.SegmentLength=obj.pSegmentLength;
        if strcmpi(obj.Method,'Welch')
            obj.sSegmentBuffer.OverlapPercent=obj.OverlapPercent;
        else
            obj.sSegmentBuffer.OverlapPercent=0;
        end




        DF=1;
        if obj.pIsDownSamplerEnabled
            DF=obj.sDDCDecimationFactor;
        end
        inputFrameLength=(obj.pSegmentLength-getNumOverlapSamples(obj))*DF;
        currentSegLen=obj.DataBuffer.SegmentLength;
        newSegLen=max(inputFrameLength,DF);
        obj.DataBuffer.SegmentLength=newSegLen;
        if(newSegLen~=currentSegLen)
            releaseDDC(obj);
        end
        obj.DataBuffer.OverlapPercent=0;
    else

        obj.DataBuffer.SegmentLength=obj.pSegmentLength;
        if strcmpi(obj.Method,'Welch')
            obj.DataBuffer.OverlapPercent=obj.OverlapPercent;
        else
            obj.DataBuffer.OverlapPercent=0;
        end
    end
end
