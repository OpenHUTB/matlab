function tt=daqdurationtt2datetimett(tt)




    if istimetable(tt)&&isprop(tt.Properties.CustomProperties,"TriggerTime")
        tt.Properties.StartTime=tt.Properties.CustomProperties.TriggerTime;
    end
end

