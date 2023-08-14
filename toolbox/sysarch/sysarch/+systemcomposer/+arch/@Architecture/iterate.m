function iterate(this,iterType,iterFunc,varargin)




































    narginchk(3,nargin);
    if~isa(iterFunc,'function_handle')
        error('systemcomposer:API:IterateFunctionInvalid',...
        message('SystemArchitecture:API:IterateFunctionInvalid').getString);
    end
    if strcmpi(iterType,"preorder")
        iterOrd=systemcomposer.IteratorDirection.PreOrder;
    elseif strcmpi(iterType,"postorder")
        iterOrd=systemcomposer.IteratorDirection.PostOrder;
    elseif strcmpi(iterType,"topdown")
        iterOrd=systemcomposer.IteratorDirection.TopDown;
    elseif strcmpi(iterType,"bottomup")
        iterOrd=systemcomposer.IteratorDirection.BottomUp;
    else
        error('systemcomposer:API:IterateOptionInvalid',...
        message('SystemArchitecture:API:IterateOptionInvalid').getString);
    end

    recurseOpt=true;
    includeArchPorts=false;
    followConnectivity=false;
    argListEnd=-1;
    for k=1:2:numel(varargin)
        if strcmp(varargin{k},"Recurse")
            recurseOpt=varargin{k+1};
        elseif strcmp(varargin{k},"IncludePorts")
            includeArchPorts=varargin{k+1};
        elseif strcmp(varargin{k},"FollowConnectivity")
            followConnectivity=varargin{k+1};
        else
            argListEnd=k;
            break;
        end
    end

    iter=internal.systemcomposer.ArchitectureIterator(iterOrd);
    iter.Recurse=recurseOpt;
    iter.IncludeArchitecturePorts=includeArchPorts;
    iter.FollowConnectivity=followConnectivity;
    iter.begin(this);
    while~isempty(iter.getElement)
        actElem=iter.getElement;
        if argListEnd==-1
            iterFunc(actElem);
        else
            iterFunc(actElem,varargin{argListEnd:end});
        end
        iter.next;
    end
end
