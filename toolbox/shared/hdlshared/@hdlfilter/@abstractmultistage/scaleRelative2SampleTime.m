function[up,down,offset,offsetScale,baseRate]=scaleRelative2SampleTime(this,rawClkReq)%#ok





















    minSampleTime=1;

    up=[rawClkReq(:).Up];
    down=[rawClkReq(:).Down];
    offset=[rawClkReq(:).Offset];
    sampleTime=[rawClkReq(:).Rate];


    for i=1:length(sampleTime)
        if sampleTime(i)==0
            sampleTime(i)=minSampleTime;
        end
    end

    baseRate=minSampleTime;

    down=floor(round((down.*(sampleTime/minSampleTime))));





    offsetScale=[];
    for i=1:length(down)
        if up(i)<=down(i)
            offsetScale=[offsetScale,0];%#ok
        else
            offsetScale=[offsetScale,1];%#ok
        end
    end