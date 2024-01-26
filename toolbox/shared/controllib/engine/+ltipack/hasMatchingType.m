function boo=hasMatchingType(op,varargin)
    InputClasses=cellfun(@class,varargin,'UniformOutput',false);

    boo=isequal(InputClasses{:})&&...
    strcmp(InputClasses{1},feval([InputClasses{1},'.toClosed'],op));