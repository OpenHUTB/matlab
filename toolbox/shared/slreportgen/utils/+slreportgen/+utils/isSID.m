function tf=isSID(objs)




















    tf=testobjs(@testfcn,objs);

    function tf=testfcn(obj)
        tf=(ischar(obj)||isstring(obj))...
        &&(~isempty(regexp(obj,":\d+$","once"))||~contains(obj,'/'));
    end
end
