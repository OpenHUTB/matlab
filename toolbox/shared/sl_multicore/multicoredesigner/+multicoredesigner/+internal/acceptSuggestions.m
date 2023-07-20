function acceptSuggestions(model,subsystems,latencies)




    if iscell(subsystems)

        for i=1:length(subsystems)
            if str2double(latencies{i})>=0
                set_param([model,'/',subsystems{i}],'Latency',latencies{i});
            end
        end
    else
        if str2double(latencies)>=0
            set_param([model,'/',subsystems],'Latency',latencies);
        end
    end
    cbinfo.model.Name=model;
    cbinfo.model.Handle=get_param(model,'Handle');
    multicoredesigner.internal.toolstrip.analyzeModel(cbinfo);
end
