


function objectTable=setTransitionCallee(Config,objectTable,datamgr)




    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    reader=datamgr.getBlockReader();
    chartObjects=Config.getSfCharts();
    for k=1:numel(chartObjects)
        chartObj=chartObjects{k};
        trans=chartObj.getTransitions();
        for p=1:numel(trans)
            tran=trans(p);
            sfBlock=tran.ParentChart().ParentBlock().getSID();
            actionAST=tran.getConditionActionAST();
            if~isempty(actionAST)
                destBlks={};
                destBlks=slci.results.getDestsForEvent(sfBlock,...
                actionAST,...
                destBlks);
                if~isempty(destBlks)
                    key=slci.results.TransitionObject.constructKey(tran.getSID());
                    [transObj,objectTable]=slci.results.cacheData('get',...
                    objectTable,...
                    reader,...
                    'getObject',...
                    key);
                    transObj.setDestSubSystems(destBlks);
                    objectTable=slci.results.cacheData('update',...
                    objectTable,...
                    key,...
                    transObj);
                end
            end
        end
    end
end
