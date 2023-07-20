

function objectTable=setTrivialTransitions(Config,objectTable,datamgr)

    reader=datamgr.getBlockReader();
    chartObjects=Config.getSfCharts();
    for k=1:numel(chartObjects)
        chartObj=chartObjects{k};

        trans=chartObj.getTransitions();
        for p=1:numel(trans)
            if trans(p).IsTrivial()&&~trans(p).IsVirtual()
                key=slci.results.TransitionObject.constructKey(...
                trans(p).getSID());
                [transObj,objectTable]=...
                slci.results.cacheData('get',objectTable,reader,...
                'getObject',key);

                transObj.setIsTrivial(true);

                objectTable=slci.results.cacheData('update',objectTable,...
                key,transObj);
            end
        end
    end
end
