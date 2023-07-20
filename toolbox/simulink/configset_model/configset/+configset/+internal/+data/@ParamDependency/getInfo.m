function depInfo=getInfo(obj)


    n=length(obj.StatusDepList);
    depInfo=cell(n,1);
    for i=1:length(obj.StatusDepList)
        dep=obj.StatusDepList{i};
        info=dep.getInfo();
        depInfo{i}=info;
    end


