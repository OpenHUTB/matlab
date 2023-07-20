function setLegacyOverlap(obj)






    if(obj.UseBufferLocal~=-1)&&~isempty(obj.BufferSizeLocal)&&~isempty(obj.OverlapLocal)
        if obj.UseBufferLocal
            val=sprintf('100 * (%s)/(%s)',obj.OverlapLocal,obj.BufferSizeLocal);
            [val_eval,~]=obj.evaluateVariable(val);
            if(~isempty(val_eval)&&isscalar(val_eval)&&isreal(val_eval)&&val_eval>=0&&val_eval<100)||(isempty(val_eval))
                obj.OverlapPercent=sprintf('100 * (%s)/(%s)',obj.OverlapLocal,obj.BufferSizeLocal);
            end
        else
            obj.OverlapPercent='0';
        end
        obj.OverlapPercent=simplifyString(obj,obj.OverlapPercent);
    end
end
