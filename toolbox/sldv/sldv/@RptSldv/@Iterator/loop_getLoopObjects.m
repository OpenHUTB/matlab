function oList=loop_getLoopObjects(h)






    oList=getList(h);

    function oList=getList(hv)
        children=find(hv);
        while~isequal(length(children),1)
            for cc=children'
                if~isempty(find(get(classhandle(cc),'methods'),'Name','listLoopObjects'))
                    oList=cc.listLoopObjects;
                    return;
                end
            end
        end
