function reevaluateBindModeStatusForObserverContextSwitch(obsMdlH,isAddContext)
    bindModeObj=BindMode.BindMode.getInstance();
    obsCtxH=getSimulinkBlockHandle(get_param(obsMdlH,'ObserverContext'));
    if~isempty(bindModeObj)&&isvalid(bindModeObj)
        parentBdHandle=bindModeObj.modelObj.Handle;
        parentBdObj=get_param(parentBdHandle,'Object');
        if obsCtxH~=-1&&bdroot(obsCtxH)==parentBdHandle
            allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            for idx=1:numel(allStudios)
                studio=allStudios(idx);
                currentBdHandle=studio.App.blockDiagramHandle;
                if currentBdHandle==obsMdlH
                    currentBdObj=get_param(currentBdHandle,'Object');
                    if isAddContext&&~BindMode.BindMode.isEnabled(currentBdObj)&&BindMode.BindMode.isEnabled(parentBdObj)
                        BindMode.BindMode.addChildModel(currentBdHandle);
                    elseif~isAddContext&&BindMode.BindMode.isEnabled(currentBdObj)&&~BindMode.BindMode.isEnabled(parentBdObj)
                        childModelHandles=cellfun(@(ob)ob.Handle,bindModeObj.childModelObjects);
                        j=find(childModelHandles==modelHandle);
                        if(numel(j)==1)
                            bindModeObj.childModelObjects(j)=[];
                            SLStudio.Utils.RemoveHighlighting(modelHandle);
                            editors=BindMode.utils.getAllEditorsForModel(modelHandle);
                            for e=1:numel(editors)
                                editors(e).sendMessageToTools('SLRemoveModelBindMode');
                            end
                        end
                    end
                end
            end
        end
    end

end

