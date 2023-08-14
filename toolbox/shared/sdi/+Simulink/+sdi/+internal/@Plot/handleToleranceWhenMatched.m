function diffRes=handleToleranceWhenMatched(this,lhsID,diffRes)


    if isempty(diffRes.Diff)
        data=this.SDIEngine.getSignal(lhsID);
        if isempty(data.DataValues)
            return
        end
        sz=size(data.DataValues.Data);
        toPlot=zeros(sz);
        if~isvector(toPlot)
            if(max(sz)==numel(toPlot))
                diffData=reshape(toPlot,1,max(sz));
            end
        else
            diffData=toPlot;
        end
        [r,c]=size(diffData);

        time=reshape(data.DataValues.Time,r,c);
        returndiffRes.Diff=timeseries(diffData,time);

        absTol=this.SDIEngine.getSignalAbsTol(lhsID);
        relTol=this.SDIEngine.getSignalRelTol(lhsID);


        tolData=max(absTol,relTol*double(data.DataValues.Data));
        tolData=reshape(tolData,r,c);
        returndiffRes.Tol=timeseries(tolData,time);
        diffRes=returndiffRes;
    end
end