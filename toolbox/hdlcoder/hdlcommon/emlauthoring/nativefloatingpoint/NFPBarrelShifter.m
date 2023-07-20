%#codegen
function y1=NFPBarrelShifter(u,s)
    coder.allowpcode('plain');
    y1=cast(0,'like',u);
    u_nt=numerictype(u);
    s_nt=numerictype(s);

    if abs(s)>u_nt.WordLength
        y1=cast(0,'like',u);
    else
        if s_nt.Signed
            if bitget(s,s_nt.WordLength)
                y1=bitsra(u,-s);
            else
                y1=bitsll(u,s);
            end
        else
            y1=bitsll(u,s);
        end
    end

