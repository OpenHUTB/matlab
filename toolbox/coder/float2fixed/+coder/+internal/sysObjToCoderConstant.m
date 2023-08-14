function c=sysObjToCoderConstant(h)
    c=struct;
    props=properties(h);
    for ii=1:numel(props)
        prop=props{ii};
        evalc('val = h.(prop);');
        if isnumeric(val)||ischar(val)||islogical(val)
            c.(prop)=val;
        end
    end
end