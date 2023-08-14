function setElapsedTimerMode(h,startTimer)




    if startTimer
        if isempty(h.ElapsedTimer)
            createElapsedTimer(h);
        end
        startElapsedTimer(h);
    else
        cleanElapsedTimer(h);
    end

end

function createElapsedTimer(h)
    t=timer;
    t.Name=getString(message('Sldv:SldvresultsSummary:ProgressUITimer'));
    t.ExecutionMode='fixedRate';
    t.Period=1;
    t.TimerFcn={@timerCB,h};

    h.ElapsedTimer=t;
end

function startElapsedTimer(h)
    tmr=h.ElapsedTimer;
    if~isempty(tmr)&&...
        isvalid(tmr)&&...
        strcmp(tmr.Running,'off')

        h.analysisStartTime=tic;
        start(tmr);
    end
end

function cleanElapsedTimer(h)
    tmr=h.ElapsedTimer;
    if~isempty(tmr)
        if strcmp(tmr.Running,'on')
            stop(tmr);
        end
        delete(tmr);
        h.ElapsedTimer=[];
    end
end


function timerCB(~,~,h)
    if h.analysisStartTime~=0

        elapsedTime=uint64(toc(h.analysisStartTime));
        if elapsedTime~=0
            h.browserparam2=elapsedTime;
        end



        h.progressHTML();
    end
end
