function traceLabel=getTrace(this,metricName,idx,toString)




    try
        traceInfo=this.getTraceInfo(metricName,idx);

        traceLabel={};
        for tIdx=1:numel(traceInfo)
            tl=traceInfo(tIdx).traceLabel;
            if~isempty(tl)
                traceLabel{end+1}=tl;%#ok<AGROW>
            end
        end

        if toString
            if isempty(traceLabel)
                traceLabel='';
            else
                traceLabel=join(traceLabel,',');
                traceLabel=traceLabel{1};
            end
        end

    catch MEx
        rethrow(MEx);
    end
end