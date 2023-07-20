












function[ids,props]=getAvailableMetrics()
    mm=slmetric.internal.MetricManager();


    f=mm.getMetricFactory('');
    ids=f.getAvailableMetrics();


    props=struct('Name',[],'Description',[],'IsBuiltIn',[],'Version',[]);

    for n=1:length(ids)
        info=f.getMetricInformation(ids{n});
        props(n).Name=info.Name;
        props(n).Description=info.Description;
        props(n).IsBuiltIn=info.IsBuiltIn;
        props(n).Version=info.Version;
    end
end
