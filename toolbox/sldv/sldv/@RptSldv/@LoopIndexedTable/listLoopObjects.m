function v=listLoopObjects(h)




    ev=evalin('base',h.Source);
    [ci,tdescr]=getCurrLoopIdx(h);
    ev=getIdxValue(h,ev,ci);

    if iscell(ev)
        s=length(ev);
        for i=1:s
            ts.descr=[h.Source,tdescr,'(',num2str(i),')'];
            ts.idx=i;
            v{i}=ts;
        end
    elseif isstruct(ev)
        fn=fieldnames(ev);
        for i=1:length(fn)
            ts.descr=[h.Source,tdescr,'.',fn{i}];
            ts.idx=fn{i};
            v{i}=ts;
        end
    end



    v=v';





