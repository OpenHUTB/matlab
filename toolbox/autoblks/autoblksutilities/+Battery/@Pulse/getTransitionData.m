function[data1,data2]=getTransitionData(obj,idx,Buffer)




























    if nargin<3
        idx1a=max(idx-1,1);
        idx1b=idx-1;
        idx2a=idx;
        idx2b=min(idx,size(obj.Data,1));
    else
        idx1a=max(idx-Buffer(1),1);
        idx1b=idx-1;
        idx2a=idx;
        idx2b=min(idx+Buffer(2),size(obj.Data,1));
    end


    data1=obj.Data(idx1a:idx1b,:);
    data2=obj.Data(idx2a:idx2b,:);