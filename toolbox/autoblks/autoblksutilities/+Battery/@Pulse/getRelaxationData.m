function data=getRelaxationData(obj,Buffer)


























    if nargin<2
        idx1=obj.idxRelax(1,1);
        idx2=obj.idxRelax(1,2);
    else
        idx1=max(obj.idxRelax(1,1)-Buffer(1),1);
        idx2=min(obj.idxRelax(1,2)+Buffer(2),size(obj.Data,1));
    end


    data=obj.Data(idx1:idx2,:);