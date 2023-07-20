function handle=timercb(timerFcn)
    handle=@(e,d)matlab.graphics.internal.drawnow.callback(timerFcn);
end