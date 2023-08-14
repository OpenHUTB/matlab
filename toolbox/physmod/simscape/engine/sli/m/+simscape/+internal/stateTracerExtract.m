function out=stateTracerExtract(st,index)






    idx=find(st.system.values.index==index);
    if numel(idx)~=1
        error("Index not found in values");
    end
    out=st.system.ss.inputs;
    for f=fields(out)'
        out.(f{:})=st.system.values.(f{:})(idx,:);
    end
end