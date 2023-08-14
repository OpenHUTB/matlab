function tetListenerCB(this,~,~)





    if~this.tetStreamingToSDI(),return;end

    time=this.tc.ModelExecProperties.ExecTime;


    slrealtime.TETMonitor.runOnce(this.TargetSettings.name,this);


    if~isempty(this.tetSDISigIds)
        tetVals=[];
        for i=1:length(this.tc.ModelExecProperties.TETInfo)
            tetVals(end+1)=double(this.tc.ModelExecProperties.TETInfo(i).TETMin);%#ok
            tetVals(end+1)=double(this.tc.ModelExecProperties.TETInfo(i).TETMax);%#ok
            tetVals(end+1)=double(this.tc.ModelExecProperties.TETInfo(i).TETAvg);%#ok
        end
        if isempty(tetVals)||any(tetVals==-1),return;end

        repository=sdi.Repository(true);

        for i=1:length(tetVals)
            repository.addSignalTimePoint(this.tetSDISigIds(i),time,tetVals(i));
        end
    end
end
