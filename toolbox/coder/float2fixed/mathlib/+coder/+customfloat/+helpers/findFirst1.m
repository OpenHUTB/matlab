%#codegen




function pos=findFirst1(x_fi)
    coder.inline('always');
    coder.allowpcode('plain');

    pos=uint8(0);

    for ii=coder.unroll(uint8(x_fi.WordLength):-1:1)
        if bitget(x_fi,ii)
            pos=ii;
            break;
        end
    end







end
