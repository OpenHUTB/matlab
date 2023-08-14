function out=getAll(obj)

    out=cellfun(@(x)obj.(x),obj.getAllPropNames,'UniformOutput',false);
end
