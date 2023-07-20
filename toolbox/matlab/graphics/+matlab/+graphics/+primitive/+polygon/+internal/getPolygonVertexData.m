function[vd,sd]=getPolygonVertexData(vertices)




    vd=vertices;
    ind=find(any(isnan(vd),2));
    vd(ind,:)=[];

    temp=ind';
    temp=temp-(1:numel(temp))+1;
    sd=uint32([1,temp,size(vd,1)+1]);
end

