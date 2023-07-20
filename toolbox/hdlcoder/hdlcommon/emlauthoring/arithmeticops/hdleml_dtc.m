%#codegen
function y=hdleml_dtc(u,outtp_ex,mode,outIsBool)


    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    eml_prefer_const(outtp_ex,mode,outIsBool);

    if isreal(u)
        y=dtc(u,outtp_ex,mode,outIsBool);
    else
        u_r=dtc(real(u),outtp_ex,mode,outIsBool);
        u_i=dtc(imag(u),outtp_ex,mode,outIsBool);
        y=complex(u_r,u_i);
    end
end


function y=dtc(u,outtp_ex,mode,outIsBool)
    eml_prefer_const(outtp_ex,mode,outIsBool);

    if mode==1

        if islogical(u)&&islogical(outtp_ex)
            y=u;
        elseif islogical(u)
            y=fi(int8(u),numerictype(outtp_ex),fimath(outtp_ex));
        elseif islogical(outtp_ex)
            y=logical(u);
        elseif outIsBool
            y=onebit_switch(u);
        elseif isfloat(outtp_ex)
            if isfloat(u)
                y=u;
            else
                y=double(u);
            end
        else
            y=fi(u,numerictype(outtp_ex),fimath(outtp_ex));
        end
    else

        if islogical(u)&&islogical(outtp_ex)
            y=u;
        elseif islogical(u)
            y=fi(int8(u),numerictype(outtp_ex),fimath(outtp_ex));
        elseif islogical(outtp_ex)
            y=logical(u);
        elseif outIsBool
            y=onebit_switch(u);
        elseif isfloat(outtp_ex)
            if isfloat(u)
                y=u;
            else
                y=double(u);
            end
        else
            nt=numerictype(outtp_ex);
            nt_u=numerictype(u);
            nt_new=numerictype(nt.SignednessBool,nt.WordLength,nt_u.FractionLength);
            ut=fi(u,nt_new,fimath(outtp_ex));
            y=eml_reinterpret(ut,numerictype(outtp_ex));
        end
    end
end

function y=onebit_switch(u)
    if u~=0
        y=fi(1,0,1,0);
    else
        y=fi(0,0,1,0);
    end
end
