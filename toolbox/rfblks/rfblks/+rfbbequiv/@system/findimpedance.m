function z0=findimpedance(h)





    z0=50;
    if isa(h.OriginalCkt,'rfckt.rfckt')
        [z0_1,z0_2]=findimpedance(h.OriginalCkt,[],[]);
        if~isempty(z0_1)
            z0=z0_1(1);
        elseif~isempty(z0_2)
            z0=z0_2(1);
        end
    end