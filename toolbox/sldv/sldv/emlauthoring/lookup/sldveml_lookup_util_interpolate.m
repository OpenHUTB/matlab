%#codegen
function out=sldveml_lookup_util_interpolate(u,xL,xR,yL,yR)





    coder.allowpcode('plain');

    if strcmp(class(xL),class(yL))
        if(xR>xL)&&(u>xL)
            den=xR-xL;
            num=u-xL;
            ydiff=yR-yL;
            bigProd=ydiff*num;
            ydiff=bigProd/den;
            out=yL+ydiff;
        else
            out=yL;
        end
    else
        if isfloat(yL)
            if(xR>xL)&&(u>xL)
                den=double(xR-xL);
                num=double(u-xL);
                ydiff=double(yR-yL);
                bigProd=ydiff*num;
                ydiff=bigProd/den;
                out=yL+cast(ydiff,class(yL));
            else
                out=yL;
            end
        else
            if(xR>xL)&&(u>xL)
                den=int32(xR-xL);
                num=int32(u-xL);
                ydiff=int32(yR-yL);
                bigProd=ydiff*num;
                ydiff=bigProd/den;
                out=yL+cast(ydiff,class(yL));
            else
                out=yL;
            end
        end
    end

end
