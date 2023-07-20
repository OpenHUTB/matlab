function data=getLoadData(obj,Buffer)


























    if nargin<2
        idx1=obj.idxLoad(1,1);
        idx2=obj.idxLoad(1,2);
    else
        idx1=max(obj.idxLoad(1,1)-Buffer(1),1);
        idx2=min(obj.idxLoad(1,2)+Buffer(2),size(obj.Data,1));
    end


    data=obj.Data(idx1:idx2,:);