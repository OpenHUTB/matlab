function out=cat(dim,varargin)







    isNumericEmpty=cellfun(@(x)isnumeric(x)&&isempty(x),varargin);
    isValidNumericEmpty=cellfun(@(x)iIsValidNumericEmpty(x),varargin(isNumericEmpty));
    if~isempty(isValidNumericEmpty)&&~all(isValidNumericEmpty)
        throwAsCaller(MException(message('MATLAB:catenate:opaqueDimensionMismatch')));
    end
    varargin=varargin(~isNumericEmpty);


    if numel(varargin)==1
        out=varargin{1};
        return
    end



    if~isnumeric(dim)||isobject(dim)||~isscalar(dim)||...
        dim~=round(dim)||dim<=0||~isfinite(dim)||~isreal(dim)
        error(message('MATLAB:catenate:invalidDimension'));
    end


    if dim==1
        error(message('optim_problemdef:OptimizationValues:indexing:HorzcatOnly'));
    elseif dim>2
        error(message('optim_problemdef:OptimizationValues:indexing:DimMustBeTwo'));
    end


    isOptimValues=cellfun(@(x)isa(x,'optim.problemdef.OptimizationValues'),varargin);
    if~all(isOptimValues)
        error(message('optim_problemdef:OptimizationValues:indexing:AllObjectsMustBeOptimizationValues'));
    end



    checkSameProperties(varargin{:});



    out=varargin{1};


    valNames=fieldnames(out.Values);
    for i=1:numel(valNames)
        allVals=cellfun(@(x)x.Values.(valNames{i}),varargin,...
        'UniformOutput',false);
        valsDim=ndims(allVals{1});
        out.Values.(valNames{i})=cat(valsDim,allVals{:});
    end


    out.NumValues=sum(cellfun(@(x)x.NumValues,varargin));

end


function isValid=iIsValidNumericEmpty(x)




    isValid=ismatrix(x);
    if~isValid
        sz=size(x);
        idx1Valid=all(sz([1,3:end])==1);
        idx0Valid=sz(2)==0;
        isValid=idx1Valid&&idx0Valid;
    end

end
