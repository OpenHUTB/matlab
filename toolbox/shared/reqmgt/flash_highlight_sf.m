function chart=flash_highlight_sf(obj_handle,mode_temp,mode_final,delay)





    chart=sf_update_style(obj_handle,mode_temp);


    t=timer('TimerFcn',@delayed_highlight,'StartDelay',delay);
    userData.obj=obj_handle;
    userData.highlight=mode_final;
    t.UserData=userData;
    start(t);

    function delayed_highlight(timerobj,varargin)

        userData=timerobj.UserData;
        obj=userData.obj;
        highlight=userData.highlight;
        stop(timerobj);
        delete(timerobj);

        if sf('ishandle',obj)
            sf_update_style(obj,highlight);
        end
