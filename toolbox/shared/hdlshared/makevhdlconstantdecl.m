function constdecl=makevhdlconstantdecl(index,value)





    vhdlconstant=hdlsignalname(index);
    vhdltype=hdlsignalvtype(index);
    comment=hdlsignalsltype(index);

    if isempty(comment)==0
        comment=['-- ',comment];
    end
    constdecl=['  CONSTANT ',sprintf('%-30s',vhdlconstant),...
    ' : ',vhdltype,' := ',value,'; ',comment,'\n'];




