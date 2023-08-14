function name=hdlsafeinput(in,outsltype,idxchar)








    name=hdlsignalname(in);
    sltype=hdlsignalsltype(in);

    array_deref=hdlgetparameter('array_deref');

    [outsize,outbp,outsigned]=hdlwordsize(outsltype);

    if isempty(sltype)
        size=1;
        bp=0;
        signed=0;
    else
        [size,bp,signed]=hdlwordsize(sltype);
    end

    if hdlgetparameter('isvhdl')
        isinport=vhdlisstdlogicvector(in);
    else
        isinport=false;
    end

    if(nargin==3)
        name=[name,array_deref(1),idxchar,array_deref(2)];
    end

    if size>1
        if isinport
            [name,size]=hdlsignaltypeconvert(name,size,signed,...
            hdlportdatatype(sltype),outsigned);
        else
            [name,size]=hdlsignaltypeconvert(name,size,signed,...
            hdlblockdatatype(sltype),outsigned);
        end
    elseif hdlgetparameter('isverilog')&&hdlisinportsignal(in)
        [name,size]=hdlsignaltypeconvert(name,size,signed,...
        hdlportdatatype(sltype),outsigned);
    end



