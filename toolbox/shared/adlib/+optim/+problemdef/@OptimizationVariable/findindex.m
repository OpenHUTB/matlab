function varargout=findindex(x,varargin)















































    if isempty(x)
        throwAsCaller(MException(message(...
        'shared_adlib:OptimizationVariable:findindex:EmptyVariable')));
    end


    szVar=size(x);
    ndimsVar=length(szVar);
    idxNonSingletonDim=szVar>1;




    ndimsSpec=nargin-1;
    isValidInput=(sum(idxNonSingletonDim)==1&&ndimsSpec==1)||...
    ndimsSpec==ndimsVar;
    if~isValidInput
        throwAsCaller(MException(message(...
        'shared_adlib:OptimizationVariable:findindex:BadNargin')));
    end


    if nargout>1&&ndimsSpec~=nargout
        throwAsCaller(MException(message(...
        'shared_adlib:OptimizationVariable:findindex:BadNargout')));
    end


    allIdxSizes=cell(1,ndimsSpec);
    for i=1:ndimsSpec
        if isempty(varargin{i})
            throwAsCaller(MException(message(...
            'shared_adlib:OptimizationVariable:findindex:EmptyIndex')));
        end
        if islogical(varargin{i})
            throwAsCaller(MException(message(...
            'shared_adlib:OptimizationVariable:findindex:MustBeStringOrNumericIndex')));
        end
        if ischar(varargin{i})
            allIdxSizes{i}=[1,1];
        else
            allIdxSizes{i}=size(varargin{i});
        end
    end


    isLinearIdx=nargout<=1;
    expectedSize=allIdxSizes{1};
    if isLinearIdx&&~all(cellfun(@(x)isequal(x,expectedSize),allIdxSizes))
        throwAsCaller(MException(message(...
        'shared_adlib:OptimizationVariable:findindex:InvalidIndexSize')));
    end


    sub=substruct('()',varargin);


    sub=optim.internal.problemdef.indexing.convertStringToNumericIdx(sub,szVar,x.IndexNames);


    varargout=cell(1,nargout);
    if isLinearIdx




        idxSubs=cellfun(@(x)x(:),sub.subs,'UniformOutput',false);
        varargout{1}=sub2ind(szVar,idxSubs{:});
    else
        varargout=sub.subs;
    end


    for i=1:nargout
        varargout{i}=reshape(varargout{i},allIdxSizes{i});
    end