function[boundarypoints,Holemap]=findBoundary(p,t)


























    warnState=warning('Off','MATLAB:triangulation:PtsNotInTriWarnId');
    TR=triangulation(t(:,1:3),p);
    fn=faceNormal(TR);

    if~all(fn(:,3)==1)
        idx=find(fn(:,3)~=1);
        temp=t(idx,1);
        t(idx,1)=t(idx,3);
        t(idx,3)=temp;
        TR=triangulation(t(:,1:3),p);
    end
    fbtri=freeBoundary(TR);

    warning(warnState);

    cellcounter=0;
    while~isempty(fbtri)
        index=find(fbtri(:,1)==fbtri(1,2));
        counter=1;
        orderlist=[];
        indexlist=[];
        orderlist(counter,:)=fbtri(1,:);%#ok<*AGROW>
        indexlist(counter)=1;
        while~isempty(index)
            counter=counter+1;
            if~isscalar(index)
                error(message('antenna:antennaerrors:UnresolvedBoundary'));
            end
            orderlist(counter,:)=fbtri(index,:);
            indexlist(counter)=index;
            index=find(fbtri(:,1)==fbtri(index,2));
            if index==indexlist(1)
                cellcounter=cellcounter+1;
                boundarypoints{cellcounter}=fbtri(indexlist);
                fbtri(indexlist,:)=[];
                break;
            end
        end
    end


    Holemap=zeros(cellcounter,cellcounter);
    for m=1:cellcounter
        for n=1:cellcounter
            [in,on]=inpolygon(p(boundarypoints{n},1),p(boundarypoints{n},2),...
            p(boundarypoints{m},1),p(boundarypoints{m},2));
            Holemap(m,n)=any(in)|any(on);
        end
        Holemap(m,m)=0;
    end


end