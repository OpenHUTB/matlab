




function[keys,objects]=getObjects(reader,varargin)
    keys=reader.getKeys();
    objects=reader.getObjects(keys);
    if nargin>1
        predicate=varargin{1};
        selected=cellfun(predicate,objects);
        objects=objects(selected);
        keys=keys(selected);
    end
end
