%#codegen
function y=hdleml_detect_change(u,ic,dt)


    coder.allowpcode('plain')
    eml_prefer_const(ic);
    eml_prefer_const(dt);

    persistent u_d;
    if isempty(u_d)
        u_d=eml_const(ic);
    end

    if dt==1
        if all(u_d~=u)
            y=true;
        else
            y=false;
        end
    else
        if all(u_d~=u)
            y=uint8(1);
        else
            y=uint8(0);
        end
    end

    u_d=u;
