function setSegmentLengthInfo(obj)





    if(obj.UseBufferLocal~=-1)&&~isempty(obj.BufferSizeLocal)
        if obj.UseBufferLocal
            obj.SegLen=obj.BufferSizeLocal;
            obj.WindowLength=obj.BufferSizeLocal;
        else


            obj.SegLen='useInputSize';
        end
    end
end
