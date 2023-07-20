function fr=ephSplit(tt)













    fr(1)=floor(tt);
    fr(2)=tt-fr(1);
    if tt>=0||fr(2)==0
        return
    end

    fr(1)=fr(1)-1;
    fr(2)=fr(2)+1;


