function h=loadobj(s)





    h=Simulink.TimeseriesArray;
    if isstruct(s)
        if~isfield(s,'Data')
            s.Data=[];
        end
        if~isfield(s,'GridFirst')
            s.GridFirst=true;
        end
        h.LoadedData=s;
    else
        h=s;
    end