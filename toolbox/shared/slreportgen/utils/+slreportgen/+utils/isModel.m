function tf=isModel(obj)







    tf=false;
    if~isempty(obj)
        try
            objH=slreportgen.utils.getSlSfHandle(obj);
        catch
            return;
        end

        tf=isValidSlObject(slroot,objH)&&...
        (objH==bdroot(objH));
    end
end