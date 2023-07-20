function cropToTimeRange(psObj,t1,t2)





























    if nargin==2
        t2=t1(2);
        t1=t1(1);
    end



    for psIdx=1:numel(psObj)


        idxRemove=(psObj(psIdx).Time<min(t1,t2))|(psObj(psIdx).Time>max(t1,t2));


        psObj(psIdx).Data(idxRemove,:)=[];


        psObj(psIdx).Data(:,1)=psObj(psIdx).Data(:,1)-psObj(psIdx).Data(1,1);

    end
