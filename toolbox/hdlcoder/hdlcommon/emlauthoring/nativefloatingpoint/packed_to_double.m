%#codegen
function Y=packed_to_double(I)


    coder.allowpcode('plain')

    [S,E,M]=float64_unpack(uint64(I));
    if(E==2047)
        if M~=0
            Y=NaN;
        else
            if(S==0)
                Y=Inf;
            else
                Y=-Inf;
            end
        end
    else
        if(E>0)
            EE=double(E);
            B=1.0;
        else
            B=0.0;
            EE=1.0;
        end

        Y=(B+double(M)*(2.0^-52.0))*(2.0^(EE-1023.0));
        if S==1
            Y=-Y;
        end
    end
end
