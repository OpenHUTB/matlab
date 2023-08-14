function lim=ensureValidLim(lim)


    if lim(1)==lim(2)
        if lim(1)==0
            lim(2)=1;
        elseif lim(1)>0
            lim(1)=0;
        else
            lim(2)=0;
        end
    end

end
