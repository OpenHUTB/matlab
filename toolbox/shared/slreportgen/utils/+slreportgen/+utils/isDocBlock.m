function tf=isDocBlock(obj)







    tf=false;
    if~isempty(obj)
        try
            objH=slreportgen.utils.getSlSfHandle(obj);
        catch
            return;
        end

        tf=isprop(objH,"BlockType")&&...
        (strcmp(get(objH,'BlockType'),"SubSystem")&&...
        strcmp(get(objH,'MaskType'),"DocBlock"));
    end
end