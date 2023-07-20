



function pauseTimeCB(cbinfo)
    handle=cbinfo.model.handle;
    times=cbinfo.EventData;
    try
        set_param(handle,'PauseTimes',times);
        if~isempty(times)
            set_param(handle,'EnablePauseTimes','on');
        else
            set_param(handle,'EnablePauseTimes','off');
        end
    catch
        set_param(handle,'EnablePauseTimes','off');
    end
end
