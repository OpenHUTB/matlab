function hdl=sps_new_private(varargin)



    narginchk(0,0);
    eventDispatcher=[];

    try

        eventDispatcher=DAStudio.EventDispatcher;
        eventDispatcher.broadcastEvent('MESleepEvent');


        open_system('power_new_palette');


        hdl=new_system('','FromTemplate','powersys_model.sltx');
        open_system(hdl);

    catch ME
        if~isempty(eventDispatcher)
            eventDispatcher.broadcastEvent('MEWakeEvent');
        end
        rethrow(ME);
    end

    eventDispatcher.broadcastEvent('MEWakeEvent');
end