function constdecl=makeverilogconstantdecl(index,value)






    if index<0||index>=hdlsignalnext
        error(message('HDLShared:directemit:badindex',index));
    end

    vconstant=hdlsignalname(index);
    vtype=hdlsignalvtype(index);
    sltype=hdlsignalsltype(index);
    [size,bp,signed]=hdlwordsize(sltype);

    array_deref=hdlgetparameter('array_deref');

    comment=sltype;
    if isempty(comment)==0
        comment=[hdlgetparameter('comment_char'),comment];
    end

    if signed&&size~=0&&size~=1
        signedstr='signed ';
        sizestr=sprintf('%s%d:0%s ',array_deref(1),size-1,array_deref(2));
    else
        signedstr='';
        sizestr='';
    end

    constdecl=['  parameter ',signedstr,sizestr,sprintf('%s',vconstant),...
    ' = ',value,'; ',comment,'\n'];




