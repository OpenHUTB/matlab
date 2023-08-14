function tf=isBusSelector(obj)







    tf=false;
    if~isempty(obj)
        try
            objH=slreportgen.utils.getSlSfHandle(obj);
        catch
            return;
        end

        tf=isnumeric(objH)&&...
        strcmp(get_param(objH,'Type'),'block')&&...
        strcmp(get_param(objH,'BlockType'),'BusSelector');
    end
end