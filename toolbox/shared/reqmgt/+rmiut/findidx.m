function[match,idx]=findidx(part,whole)










    partCnt=length(part);
    [~,Iwhole,Ipart]=intersect(whole,part,'legacy');

    if(length(Ipart)~=partCnt)
        error(message('Slvnv:reqmgt:util_findidx:PoorInput'));
    end

    Irev(Ipart)=1:partCnt;
    idx=Iwhole(Irev);
    match=false(length(whole),1);
    match(idx)=true;
