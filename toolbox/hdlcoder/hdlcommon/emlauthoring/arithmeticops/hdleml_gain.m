%#codegen
function y=hdleml_gain(u,gain_const,outtp_ex,gain_mode)


    coder.allowpcode('plain')
    eml_prefer_const(gain_const,outtp_ex,gain_mode);

    if nargin<3
        gain_mode=1;
    end


    if isfloat(u)
        if gain_mode==1
            y=gain_const.*u;
        elseif gain_mode==2
            y=u*gain_const;
        else
            y=gain_const*u;
        end

    else

        if gain_mode==1
            y=hdleml_product(gain_const,u,outtp_ex);
        elseif gain_mode==2
            y=hdleml_matrix_product(u,gain_const,outtp_ex);
        else
            y=hdleml_matrix_product(gain_const,u,outtp_ex);
        end
    end

