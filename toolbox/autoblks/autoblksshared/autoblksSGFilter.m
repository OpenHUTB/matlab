function[y,dy,xbuff_out,j_out,dyold_out]=autoblksSGFilter(x,g,Ts,div0Tol,xbuff,j,dyold)
%#codegen

    coder.allowpcode('plain')
    y=double(0.);
    dy=double(0.);
    k=int32(0);



    if j<size(g,1)
        j=j+int32(1);
    else
        j=int32(1);
    end


    xbuff(j)=x;
    xbuff_out=xbuff;
    xbuff_out(j)=x;
    j_out=j;

    for i=int32(1):size(g,1)
        if(j+i)<=size(g,1)
            k=j+i;
        else
            k=j+i-size(g,1);
        end
        y=y+g(i,1)*xbuff(k);
        dy=dy+g(i,2)*xbuff(k);
    end
    if Ts<=div0Tol
        dy=dyold;
    else
        dy=dy/Ts;
    end
    dyold_out=dy;