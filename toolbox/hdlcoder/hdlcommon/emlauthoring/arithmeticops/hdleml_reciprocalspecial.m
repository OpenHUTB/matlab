%#codegen
function y=hdleml_reciprocalspecial(u,mode,...
    Div_zero,Div_posone,Div_negone,Div_negtwo,...
    Const_zero,Const_posone,Const_negone,Const_negtwo,...
    Input_posone,Input_negone,Input_negtwo)






    coder.allowpcode('plain')
    eml_prefer_const(mode,...
    Div_zero,Div_posone,Div_negone,Div_negtwo,...
    Const_zero,Const_posone,Const_negone,Const_negtwo,...
    Input_posone,Input_negone,Input_negtwo);

    if mode==1

        if u==0
            y=Div_zero;
        else
            y=Div_posone;
        end

    elseif mode==2

        if u>Input_posone
            y=Const_zero;
        else
            y=Const_posone;
        end

    elseif mode==3

        if u==0
            y=Div_zero;
        elseif u==Input_posone
            y=Div_posone;
        elseif u==Input_negone
            y=Div_negone;
        else
            y=Div_negtwo;
        end

    else

        if issigned(u)
            if u>Input_posone||u<Input_negone
                y=Const_zero;
            elseif u>=0
                y=Const_posone;
            elseif u<Input_negtwo
                y=Const_negone;
            else
                y=Const_negtwo;
            end
        else
            if u>Input_posone
                y=Const_zero;
            else
                y=Const_posone;
            end
        end
    end



