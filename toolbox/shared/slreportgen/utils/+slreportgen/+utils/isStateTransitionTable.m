function tf=isStateTransitionTable(objs)










    tf=testobjs(@testfcn,objs);

    function tf=testfcn(obj)
        tf=false;
        if~isempty(obj)
            try
                objH=slreportgen.utils.getSlSfHandle(obj);
            catch
                return;
            end

            if isa(objH,"Stateflow.Object")
                tf=isa(objH,"Stateflow.StateTransitionTableChart");
            else
                if(isprop(objH,"BlockType")&&strcmp(get_param(objH,"BlockType"),"SubSystem"))
                    chartObj=slreportgen.utils.block2chart(objH);
                    tf=isa(chartObj,"Stateflow.StateTransitionTableChart");
                end
            end
        end
    end
end