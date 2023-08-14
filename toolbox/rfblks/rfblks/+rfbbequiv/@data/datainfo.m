function info=datainfo(h)





    info='';


    if~isempty(get(h,'S_Parameters'))&&...
        hasnoisereference(h)&&haspowerreference(h)
        info='All Data';
    elseif~isempty(get(h,'S_Parameters'))&&haspowerreference(h)
        info='Power Data with Network Parameters';
    elseif haspowerreference(h)&&hasnoisereference(h)
        info='Power Data with Noise Data';
    elseif~isempty(get(h,'S_Parameters'))&&hasnoisereference(h)
        info='Network Parameters With Noise Data';
    elseif haspowerreference(h)
        info='Power Data Only';
    elseif~isempty(get(h,'S_Parameters'))
        info='Network Parameters Only';
    elseif hasnoisereference(h)
        info='Noise Data Only';
    end
