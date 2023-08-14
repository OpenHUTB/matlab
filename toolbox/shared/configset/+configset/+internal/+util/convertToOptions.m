function opts=convertToOptions(avs)


    n=length(avs);
    opts=cell(1,n);
    for j=1:n
        a=avs(j);
        w=[];
        w.value=a.str;
        if isfield(a,'disp')
            w.label=a.disp;
        elseif isfield(a,'key')&&~isempty(a.key)
            w.label=configset.internal.getMessage(a.key);
        else
            w.label=a.str;
        end
        opts{j}=w;
    end

