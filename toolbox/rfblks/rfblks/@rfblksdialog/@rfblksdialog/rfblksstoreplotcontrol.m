function rfblksstoreplotcontrol(source,dialog,tag,allparam)





    idx=getWidgetValue(dialog,tag)+1;
    value=allparam{idx};
    power_nature={'Pout','Phase','LS11','LS21','LS12','LS22'};


    if strcmpi(tag,'NetworkData1')&&any(strcmpi(value,power_nature))&&...
        ~any(strcmpi(source.block.UserData.NetworkData1,power_nature))
        source.block.UserData.XParameter='Pin';
    end

    eval(['source.block.UserData.',tag,' = value;']);


