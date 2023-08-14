function h=loadobj(s)

    h=Simulink.TimeseriesDataConstructor;
    if isstruct(s)
        if isfield(s,'Constructor')
            h.Constructor=s.Constructor;
        end
        if isfield(s,'Data')
            h.Data=s.Data;
        end
    else
        h=s;
    end