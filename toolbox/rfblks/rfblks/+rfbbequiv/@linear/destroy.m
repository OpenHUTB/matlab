function h=destroy(h,destroyData)





    if get(h,'DeleteCkt')&&isa(h.RFckt,'rfckt.rfckt')
        delete(h.RFckt);
    end
