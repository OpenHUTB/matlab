function tStop=findStops(v,th,dt)












    isStopped=v<th;
    isStopping=[false;diff(isStopped)==1];


    iStop=find(isStopping);
    tStop=nan(size(iStop));
    iStop=[iStop;numel(isStopping)+1];
    for k=1:numel(iStop)-1
        tStop(k)=nnz(isStopped(iStop(k):iStop(k+1)-1));
    end
    tStop=tStop*dt;
end