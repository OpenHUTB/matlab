function exportToMOrMat(filename,vidObjs,varNames,mfile)









    numVidObjs=length(vidObjs);
    errorFcn=cell(1,numVidObjs);
    framesAcquiredFcn=cell(1,numVidObjs);
    framesAcquiredFcnCount=cell(1,numVidObjs);
    startFcn=cell(1,numVidObjs);
    stopFcn=cell(1,numVidObjs);
    timerFcn=cell(1,numVidObjs);
    timerPeriod=cell(1,numVidObjs);
    triggerFcn=cell(1,numVidObjs);
    userdata=cell(1,numVidObjs);






    for j=1:numVidObjs
        errorFcn{j}=vidObjs(j).ErrorFcn;
        framesAcquiredFcn{j}=vidObjs(j).FramesAcquiredFcn;
        framesAcquiredFcnCount{j}=vidObjs(j).FramesAcquiredFcnCount;
        startFcn{j}=vidObjs(j).StartFcn;
        stopFcn{j}=vidObjs(j).StopFcn;
        timerFcn{j}=vidObjs(j).TimerFcn;
        timerPeriod{j}=vidObjs(j).TimerPeriod;
        triggerFcn{j}=vidObjs(j).TriggerFcn;
        userdata{j}=vidObjs(j).UserData;

        info=propinfo(vidObjs(j));

        vidObjs(j).ErrorFcn=info.ErrorFcn.DefaultValue;
        vidObjs(j).FramesAcquiredFcn=info.FramesAcquiredFcn.DefaultValue;
        vidObjs(j).FramesAcquiredFcnCount=info.FramesAcquiredFcnCount.DefaultValue;
        vidObjs(j).StartFcn=info.StartFcn.DefaultValue;
        vidObjs(j).StopFcn=info.StopFcn.DefaultValue;
        vidObjs(j).TimerFcn=info.TimerFcn.DefaultValue;
        vidObjs(j).TimerPeriod=info.TimerPeriod.DefaultValue;
        vidObjs(j).TriggerFcn=info.TriggerFcn.DefaultValue;
        vidObjs(j).UserData=info.UserData.DefaultValue;
    end

    if(mfile)
        obj2mfile(vidObjs,filename);
    else

        for i=1:length(varNames)
            eval([varNames{i},' = vidObjs(i);']);
        end


        save(filename,varNames{:});
    end


    for j=1:length(vidObjs)
        vidObjs(j).ErrorFcn=errorFcn{j};
        vidObjs(j).FramesAcquiredFcn=framesAcquiredFcn{j};
        vidObjs(j).FramesAcquiredFcnCount=framesAcquiredFcnCount{j};
        vidObjs(j).StartFcn=startFcn{j};
        vidObjs(j).StopFcn=stopFcn{j};
        vidObjs(j).TimerFcn=timerFcn{j};
        vidObjs(j).TimerPeriod=timerPeriod{j};
        vidObjs(j).TriggerFcn=triggerFcn{j};
        vidObjs(j).UserData=userdata{j};
    end

end
