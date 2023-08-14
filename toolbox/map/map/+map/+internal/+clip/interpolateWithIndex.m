function vq=interpolateWithIndex(v,I,interpfun)





































    if nargin<3
        interpfun=@interpolateLinear;
    end

    if isempty(I)
        vq=reshape([],[0,1]);
    else

        p=(I==round(I));
        q=I(p);


        vq=NaN(size(I),'like',v);



        vq(p)=v(q);


        k=~p&~isnan(I);
        if any(k)
            [v0,v1,f]=decodeIndex(k,v,I);
            vq(k)=interpfun(v0,v1,f);
        end
    end
end


function[v0,v1,f]=decodeIndex(k,v,I)




    i0=floor(I(k));


    f=I(k)-floor(I(k));

    v0=v(i0);
    v1=v(i0+1);
end


function v=interpolateLinear(v0,v1,f)



    v=(1-f).*v0+f.*v1;
end
