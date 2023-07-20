function asset=parenAssign(asset,s,varargin)





    assert(s(1).Type==matlab.internal.indexing.IndexingOperationType.Paren);

    if numel(s)==1

        if isempty(asset)

            asset=varargin{1};
        else

            rhsHandles=varargin{1}.Handles;


            [asset.Handles(s.Indices{:})]=rhsHandles;
        end
    else

        handles=asset.Handles(s(1).Indices{:});
        h=[handles{:}];


        [h.(s(2:end))]=varargin{:};
    end
end

