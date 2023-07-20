function tf=isPreLookup(objs)









    tf=lutdesigner.report.utils.testobjs(@testfcn,objs);

    function tf=testfcn(obj)
        tf=false;
        if~isempty(obj)
            try
                objH=slreportgen.utils.getSlSfHandle(obj);
            catch
                return;
            end

            tf=isprop(objH,"BlockType")&&...
            (strcmp(get(objH,'BlockType'),"PreLookup"));

        end
    end
end
