function setFixptSettingtoDfilt(this,Hd,fromSLtype,HdWordL,HdFracL)





    if~strcmpi(this.(fromSLtype),'double')
        [sz,bp]=hdlgetsizesfromtype(this.(fromSLtype));

        Hd.(HdWordL)=sz;
        Hd.(HdFracL)=bp;
    end

