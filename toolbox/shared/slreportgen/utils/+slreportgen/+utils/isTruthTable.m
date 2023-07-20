function tf=isTruthTable(objs)









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
                tf=isa(objH,'Stateflow.TruthTable');
            else
                if(isprop(objH,'BlockType')&&strcmp(get(objH,'BlockType'),'SubSystem'))
                    chartId=sfprivate('block2chart',objH);
                    if(chartId>0)
                        r=slroot();
                        chartObj=r.idToHandle(chartId);
                        tf=isa(chartObj,'Stateflow.TruthTableChart');
                    end
                end
            end
        end
    end
end

