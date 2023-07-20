function tf=isLookupTable(objs)








    tf=testobjs(@testfcn,objs);

    function tf=testfcn(obj)
        tf=false;
        if~isempty(obj)
            try
                objH=slreportgen.utils.getSlSfHandle(obj);
            catch
                return;
            end

            tf=isprop(objH,"BlockType")&&...
            (strcmp(get(objH,'BlockType'),"Lookup_n-D")||...
            strcmp(get(objH,'BlockType'),"Interpolation_n-D")||...
            strcmp(get(objH,'BlockType'),"LookupNDDirect")||...
            (strcmp(get(objH,'BlockType'),"S-Function")&&...
            strcmp(get(objH,'MaskType'),"Lookup Table Dynamic")));

        end
    end
end