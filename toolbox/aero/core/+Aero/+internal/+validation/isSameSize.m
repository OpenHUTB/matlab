function tf=isSameSize(a,b)




    sa=size(a);
    sb=size(b);

    tf=(numel(sa)==numel(sb))&&all(sa==sb);

end

