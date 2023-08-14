function[y,dy]=autoblksSGFilterSingle(x,g,Ts)

%#codegen
    coder.allowpcode('plain')


    persistent xbuff j
    if isempty(xbuff)
        xbuff=single(zeros(size(g,1),1));
    end
    if isempty(j),j=int32(0);end

    y=single(0.);
    dy=single(0.);
    k=int32(0);


    if j<size(g,1)
        j=j+int32(1);
    else
        j=int32(1);
    end


    xbuff(j)=x;


    for i=int32(1):size(g,1)
        if(j+i)<=size(g,1)
            k=j+i;
        else
            k=j+i-size(g,1);
        end
        y=y+g(i,1)*xbuff(k);
        dy=dy+g(i,2)*xbuff(k);
    end
    dy=dy/Ts;