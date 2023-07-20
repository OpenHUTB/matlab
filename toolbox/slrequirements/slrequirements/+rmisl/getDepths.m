function allDepths=find_depths(allObjPidx)





    cnt=length(allObjPidx);
    allDepths=zeros(cnt,1);

    for i=2:cnt
        allDepths(i)=allDepths(allObjPidx(i))+1;
    end
end
