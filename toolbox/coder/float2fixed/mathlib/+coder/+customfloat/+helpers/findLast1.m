%#codegen





function pos=findLast1(x_fi)
    coder.inline('always');
    coder.allowpcode('plain');

    pos=uint8(0);

    for ii=coder.unroll(1:1:uint8(x_fi.WordLength))
        if bitget(x_fi,ii)
            pos=ii;
            break;
        end
    end







end