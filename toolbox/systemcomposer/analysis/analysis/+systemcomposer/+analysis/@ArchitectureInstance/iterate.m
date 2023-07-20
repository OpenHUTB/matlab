function iterate(this,iterType,iterFunc,varargin)


























    if isempty(this.Specification)
        error('systemcomposer:analysis:cantUpdateWithoutArchitecture',...
        message('SystemArchitecture:Analysis:CantUpdateWithoutArchitecture').getString);
    end

    narginchk(3,nargin);
    if~isa(iterFunc,'function_handle')
        error('systemcomposer:API:IterateFunctionInvalid',...
        message('SystemArchitecture:API:IterateFunctionInvalid').getString);
    end
    if ischar(iterType)
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
    else
        iterOrd=systemcomposer.IteratorDirection(iterType);
    end

    includePorts=false;
    includeConnectors=false;
    argListEnd=-1;
    for k=1:2:numel(varargin)
        if strcmp(varargin{k},"IncludePorts")
            includePorts=varargin{k+1};
        elseif strcmp(varargin{k},"IncludeConnectors")
            includeConnectors=varargin{k+1};
        else
            argListEnd=k;
            break;
        end
    end

    iter=systemcomposer.internal.analysis.iterators.InstanceModelIterator(...
    iterOrd,includePorts,includeConnectors);

    iter.begin(this.getImpl);
    while~isempty(iter.getElement)
        actElem=iter.getElement;
        try
            if argListEnd==-1
                iterFunc(actElem);
            else
                iterFunc(actElem,varargin{argListEnd:end});
            end
        catch exception
            instanceException=MException('Analysis:InvalidInstance',actElem.getInstance.UUID);
            exception=addCause(exception,instanceException);
            rethrow(exception);
        end
        iter.next;
    end
end
