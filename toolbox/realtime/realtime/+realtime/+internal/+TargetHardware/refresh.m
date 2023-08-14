function refresh()






    realtime.internal.TargetHardware.getInstance('destroy');

    if mislocked('realtime.internal.TargetHardware')
        munlock('realtime.internal.TargetHardware');
    end
    clear('realtime.internal.TargetHardware');
    clear(fullfile('+realtime','+internal','@TargetHardware','TargetHardware'));

    realtime.internal.TargetHardware.getInstance('refresh');
end