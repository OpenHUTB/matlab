function s=convertToJavaCompatibleStruct(obj)
    if isempty(obj)
        s=[];
    else
        props=fields(obj);
        for i=1:numel(props)
            s.(props{i})=obj.(props{i});
        end
    end
end