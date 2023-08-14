function tf=isCommented(objs)








    tf=testobjs(@testfcn,objs);

    function tf=testfcn(obj)
        tf=false;
        if~isempty(obj)
            try
                objH=slreportgen.utils.getSlSfHandle(obj);
            catch
                return;
            end
            if isa(objH,'Stateflow.Object')
                tf=isCommented(objH);
            else
                if isprop(objH,'Commented')
                    commented=get(objH,'Commented');
                    tf=(strcmp(commented,'on')|strcmp(commented,'through'));
                end
            end
        end
    end
end