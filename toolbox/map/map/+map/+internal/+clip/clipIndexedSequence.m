function[J,u]=clipIndexedSequence(I,v,vmin,vmax)


































































































    I=I(:);
    v=v(:);
    [I,v]=map.internal.clip.removeExtraNaNs(I(:),v(:));
    if isempty(v)||all(vmin<=v&v<=vmax)
        J=I;
        u=v;
    else
        if isfinite(vmax)&&any(v>vmax)
            [J,u]=clipToMaximum(I,v,vmax);
        else
            J=I;
            u=v;
        end

        if isfinite(vmin)&&any(v<vmin)
            [J,u]=clipToMaximum(J,-u,-vmin);
            u=-u;
        end
    end
end


function[J,u]=clipToMaximum(I,v,vmax)


    signDiff=diff(sign(v-vmax));
    crossing=find(abs(signDiff)==2);


    n=numel(crossing);
    J=NaN(size(I)+[n,0]);
    u=J;


    p=1;
    s=1;

    for m=1:numel(crossing)

        k=crossing(m);
        d=v(k+1)-v(k);
        w=(vmax-v(k))/d;




        e=k+m-1;
        J(s:e)=I(p:k);
        u(s:e)=v(p:k);



        J(e+1)=(1-w)*I(k)+w*I(k+1);
        u(e+1)=vmax;


        p=k+1;
        s=e+2;
    end


    J(s:end)=I(p:end);
    u(s:end)=v(p:end);



    q=(u>vmax)|isnan(u);
    J(q)=NaN;
    u(q)=NaN;
    [J,u]=map.internal.clip.removeExtraNaNs(J,u);
end
