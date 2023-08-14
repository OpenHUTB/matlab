function out=sortByDependency(cs,props,varargin)



    mcs=configset.internal.getConfigSetStaticData;

    if nargin==3
        adp=varargin{1};
    else
        adp=configset.internal.data.ConfigSetAdapter(cs);
    end

    n=length(props);
    m=length(mcs.ParamList);
    len=n+m;
    arr=zeros(len,1);
    k=1;
    removed=0;
    for i=1:n
        name=props{i};
        p=adp.getParamData(name,mcs);
        if isempty(p)||isempty(p.Order)

            arr(m+k)=i;
            k=k+1;
        else
            if arr(p.Order)

                removed=removed+1;
            else
                arr(p.Order)=i;
            end
        end
    end

    out=cell(n-removed,1);
    id=1;
    for i=1:len
        if arr(i)
            out{id}=props{arr(i)};
            id=id+1;
        end
    end

