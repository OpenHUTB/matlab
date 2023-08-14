function tf=testobjs(testfcn,objs)



















    if isempty(objs)
        tf=feval(testfcn,objs);
    else
        if ischar(objs)
            objs={objs};
        end

        n=numel(objs);
        tf=false(size(objs));
        if iscell(objs)
            for i=1:n
                obj=objs{i};
                tf(i)=feval(testfcn,obj);
            end
        else
            for i=1:n
                obj=objs(i);
                tf(i)=feval(testfcn,obj);
            end
        end
    end
end