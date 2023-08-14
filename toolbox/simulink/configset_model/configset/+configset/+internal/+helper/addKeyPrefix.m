function out=addKeyPrefix(key_prefix,in)



    if isempty(in)
        out=in;
    elseif isnumeric(in)
        out=in;
    elseif ischar(in)
        out=[key_prefix,in];
    elseif isstruct(in)
        props=fields(in);
        for i=1:length(props)
            p=props{i};
            out.(p)=configset.internal.helper.addKeyPrefix(key_prefix,in.(p));
        end
    elseif iscell(in)
        out=cell(size(in));
        for i=1:length(in)
            out{i}=configset.internal.helper.addKeyPrefix(key_prefix,in{i});
        end
    end




