function z0=findimpedance(h)





    z0=50;
    if isa(h.RFckt,'rfckt.rfckt')
        [z0_1,z0_2]=findimpedance(h.RFckt,[],[]);
        if~isempty(z0_1)
            z0=z0_1(1);
        elseif~isempty(z0_2)
            z0=z0_2(1);
        end
    end