function build(h)





    [junk,idx]=setdiff(get(h.getvars,{'Name'}),{'Time','Quality'});
    if isempty(idx)
        error(message('Simulink:Timeseries:nostrore'))
    end
    hStore=h.Data_(idx);
    if~isempty(hStore.Dataconstructor)
        try
            hStore.Data=feval(hStore.Dataconstructor{:});
        catch
            if length(hStore.Dataconstructor)>=2
                hStore.Data=hStore.Dataconstructor{2};
                warning(message('Simulink:Logging:SlTimeseriesCustomConstructorErr'));
            else
                error(message('Simulink:Logging:SlTimeseriesInvconst'));
            end
        end
    end
