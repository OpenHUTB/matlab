%#codegen
function[E,M]=float64_round(AE,AM,TrOne,TrSuf)


    coder.allowpcode('plain')



    E=AE;
    if(E==2047)
        M=uint64(0);
    else

        M=AM;

        if(E~=0)
            M=bitset(M,53,0);
        end

        if(TrOne&&(bitget(M,1)||TrSuf))
            M=M+1;
            if(bitget(M,53))
                E=E+1;
                M=bitset(M,53,0);
            end
        end
    end

end
