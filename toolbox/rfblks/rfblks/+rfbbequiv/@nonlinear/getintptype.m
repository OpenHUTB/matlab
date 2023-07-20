function intptype=getintptype(h)






    intptype='linear';


    ckt=get(h,'RFckt');


    if~isempty(ckt)
        intptype=get(ckt,'IntpType');
    end
