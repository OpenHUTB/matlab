function sizes=hdlcheckslsizes(sizes)







    if sizes(1)>128
        sizes(1)=128;
        warning(message('hdlcoder:makehdl:wloverflow'));
    end





    if sizes(2)>1022
        sizes(2)=1022;
        warning(message('hdlcoder:makehdl:bpoverflowneg'));
    elseif sizes(2)<-1024
        sizes(2)=-1024;
        warning(message('hdlcoder:makehdl:bpoverflow'));
    end
