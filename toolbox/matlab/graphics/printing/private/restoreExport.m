function restoreExport(old)








    old.prop=cellfun(@LocalConvertToCell,old.prop,'UniformOutput',false);
    old.values=cellfun(@LocalConvertToCell,old.values,'UniformOutput',false);

    for n=1:length(old.objs)



        hObj=old.objs{n};
        validHandles=ishandle(hObj)&LocalIsProp(hObj,old.prop{n});

        hObj=hObj(validHandles);
        values=old.values{n};
        if iscell(values)
            values=values(validHandles);
        end
        if~isempty(hObj)
            set(hObj,old.prop{n},values)
        end
    end
end

function results=LocalIsProp(h,prop)
    results=zeros(size(h));
    for i=1:length(h)
        try
            get(h(i),prop);
            results(i)=1;
        catch
        end
    end
end

function result=LocalConvertToCell(input)
    if~iscell(input)
        result={input};
    else
        result=input;
    end
end