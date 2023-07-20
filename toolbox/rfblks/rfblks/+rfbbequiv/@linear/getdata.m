function data=getdata(h)







    ckt=get(h,'RFckt');


    if isempty(ckt)
        data=[];
    else
        data=getdata(ckt);
    end
