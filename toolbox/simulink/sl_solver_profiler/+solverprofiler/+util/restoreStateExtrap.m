function xi=restoreStateExtrap(tp,xp,ti)

    if(length(tp)==2)
        xi=interp1(tp,xp,ti);
        return;
    end

    t=unique([ti;tp]);




    ids=zeros(length(t),1);
    id=2;

    [~,inds,~]=intersect(t,tp);


    ids(inds(1):inds(2))=2;

    for i=3:length(inds)
        ids(inds(i-1):inds(i))=id;
        id=id+1;
    end

    ids(ids>length(tp))=length(tp);


    t1=tp(ids-1);
    t2=tp(ids);
    x1=xp(ids-1);
    x2=xp(ids);


    x=((x2-x1)./(t2-t1)).*(t-t2)+x2;


    inds=ismembc(t,ti);
    xi=x(inds);
end