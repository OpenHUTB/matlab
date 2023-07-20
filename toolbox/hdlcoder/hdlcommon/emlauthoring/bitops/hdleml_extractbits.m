%#codegen
function y=hdleml_extractbits(msb,lsb,mode,u)


    coder.allowpcode('plain')
    eml_prefer_const(msb,lsb,mode);

    if isreal(u)
        y=extractbits(msb,lsb,mode,u);
    else
        u_r=extractbits(msb,lsb,mode,real(u));
        u_i=extractbits(msb,lsb,mode,imag(u));
        y=complex(u_r,u_i);
    end


    function y=extractbits(msb,lsb,mode,u)

        if(mode==1)
            y=extractbits_int_eml(u,msb,lsb);
        else
            y=extractbits_preservescaling_eml(u,msb,lsb);
        end

        function y=extractbits_preservescaling_eml(u,msb,lsb)

            if isfi(u)
                t=bitsliceget(u,msb,lsb);
                nt=numerictype(u);

                ySigned=nt.Signed;
                yNumBits=msb-lsb+1;
                yFracBits=nt.FractionLength-lsb+1;

                if~ySigned

                    y=rescale(t,yFracBits);
                else
                    nt2=numerictype(1,yNumBits,yFracBits);
                    y=eml_reinterpret(t,nt2);
                end
            end

            function y=extractbits_int_eml(u,msb,lsb)

                if isfi(u)
                    nt=numerictype(u);
                    if~nt.Signed

                        y=bitsliceget(u,msb,lsb);
                    else

                        t=bitsliceget(u,msb,lsb);

                        nt2=numerictype(1,msb-lsb+1,0);
                        y=eml_reinterpret(t,nt2);
                    end
                else
                    y=u;
                end
