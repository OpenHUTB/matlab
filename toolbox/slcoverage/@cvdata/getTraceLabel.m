function res=getTraceLabel(this,traceId)



    try
        res=[];
        if isempty(this.traceMap)
            return;
        end
        res=this.traceMap(traceId);
        res=res.traceLabel;
    catch MEx
        rethrow(MEx);
    end
end