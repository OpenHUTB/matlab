function predList=getPredecessors(adjList,varargin)

















    if~issparse(adjList)
        adjList=sparse(adjList);
    end

    if nargin>1
        idx=varargin{1};
    else
        idx=[];
    end

    if isempty(idx)

        n=length(adjList);
        predList=cell(1,n);

        for i=1:n
            predList{i}=find(adjList(:,i));
        end
    else
        predList=num2cell(find(adjList(:,idx)));
    end

end
