function status=getStatus(obj,cs,name,varargin)


    custom=0;
    n=length(obj.CustomDepList);
    if n>0
        st=zeros(n,1);
        for i=1:n
            dep=obj.CustomDepList{i};
            st(i)=dep.getStatus(cs,name);
        end
        custom=max(st);
    end

    n=length(obj.StatusDepList);
    if n>0
        if nargin>=4
            adp=varargin{1};
        else
            adp=configset.internal.getConfigSetAdapter(cs);
        end
    end

    for i=1:n
        dep=obj.StatusDepList{i};
        if dep.StatusLimit<=custom
            status=custom;
            return;
        end

        status=dep.getStatus(cs,adp);
        if status
            return;
        end
    end

    status=custom;
