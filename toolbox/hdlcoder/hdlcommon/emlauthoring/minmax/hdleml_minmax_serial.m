%#codegen
function y=hdleml_minmax_serial(u,mode)


    coder.allowpcode('plain')
    eml_prefer_const(mode);

    y=u(1);
    for ii=2:length(u)

        if(mode==1)
            t=u(ii)<y;
        else
            t=u(ii)>y;
        end

        if(t)
            y=u(ii);
        end

    end
