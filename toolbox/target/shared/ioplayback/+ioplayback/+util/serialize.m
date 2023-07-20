function payload=serialize(varargin)



    payload=uint8([]);
    for k=1:nargin
        if ismember(class(varargin{k}),{'char','logical'})
            payload=[payload,uint8(varargin{k})];%#ok<*AGROW>
        else
            payload=[payload,typecast(varargin{k},'uint8')];
        end
    end
end
