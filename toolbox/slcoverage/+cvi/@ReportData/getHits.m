function[hits,justifiedHits]=getHits(dataMat,idx,justifiedIdx,allColoumns)



    if nargin<4
        allColoumns=true;
    end
    if allColoumns
        hits=dataMat(idx+1,:);
        justifiedHits=0;
        if justifiedIdx>0
            justifiedHits=dataMat(justifiedIdx+1,:);
        end
    else
        hits=dataMat(idx+1);
        justifiedHits=0;
        if justifiedIdx>0
            justifiedHits=dataMat(justifiedIdx+1);
        end
    end
end

