function succList=getSuccessors(adjList,varargin)

















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
        succList=cell(1,n);

        for i=1:n
            succList{i}=find(adjList(i,:)');
        end
    else
        succList=num2cell(find(adjList(idx,:)'));
    end
end
