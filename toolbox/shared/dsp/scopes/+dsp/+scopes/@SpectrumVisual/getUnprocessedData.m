function newData=getUnprocessedData(this,data,i)






    segLen=size(data,1);

    ind=getNumOverlapSamples(this,segLen);
    data=data(ind+1:segLen,:,:);

    newData=reshape(data(:,i:size(data,2),:),size(data,1)*(size(data,2)-i+1),size(data,3));
end
