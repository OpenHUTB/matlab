function out=modelHasTerminateSS(modelName)






    out=false;
    sampleTimes=get_param(modelName,'SampleTimes');
    for i=1:length(sampleTimes)
        currentSTime=sampleTimes(i).Value;
        if length(currentSTime)>1&&currentSTime(2)==2
            out=true;
            return;
        end
    end
end