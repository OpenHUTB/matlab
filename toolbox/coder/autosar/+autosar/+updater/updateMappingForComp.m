function updateMappingForComp(matcher,oldM3IModel,newM3IComp)









    transaction=M3I.Transaction(oldM3IModel);
    oldComp=matcher.get(newM3IComp);
    if oldComp.isvalid()
        oldComp.Name=newM3IComp.Name;
    end
    transaction.commit();


    transaction=M3I.Transaction(oldM3IModel);
    for portIndex=1:newM3IComp.Port.size()
        newPort=newM3IComp.Port.at(portIndex);
        oldPort=matcher.get(newPort);
        if oldPort.isvalid()
            oldPort.Name=newPort.Name;
        end
    end
    transaction.commit();

    isCompositionComponent=autosar.composition.Utils.isM3IComposition(newM3IComp);
    if isCompositionComponent

        transaction=M3I.Transaction(oldM3IModel);
        for compIndex=1:newM3IComp.Components.size()
            newComp=newM3IComp.Components.at(compIndex);
            oldComp=matcher.get(newComp);
            if oldComp.isvalid()
                oldComp.Name=newComp.Name;
            end
        end
        transaction.commit();
    end

    componentHasBehavior=~isCompositionComponent&&newM3IComp.Behavior.isvalid();

    if componentHasBehavior

        transaction=M3I.Transaction(oldM3IModel);
        for runnableIndex=1:newM3IComp.Behavior.Runnables.size()
            newObj=newM3IComp.Behavior.Runnables.at(runnableIndex);
            oldObj=matcher.get(newObj);
            if oldObj.isvalid()
                oldObj.Name=newObj.Name;
                oldObj.symbol=newObj.symbol;
            end
        end
        transaction.commit();


        transaction=M3I.Transaction(oldM3IModel);
        for arTypedPIMIdx=1:newM3IComp.Behavior.ArTypedPIM.size()
            newObj=newM3IComp.Behavior.ArTypedPIM.at(arTypedPIMIdx);
            oldObj=matcher.get(newObj);
            if oldObj.isvalid()
                oldObj.Name=newObj.Name;
            end
        end
        transaction.commit();


        transaction=M3I.Transaction(oldM3IModel);
        for staticMemIdx=1:newM3IComp.Behavior.StaticMemory.size()
            newObj=newM3IComp.Behavior.StaticMemory.at(staticMemIdx);
            oldObj=matcher.get(newObj);
            if oldObj.isvalid()
                oldObj.Name=newObj.Name;
            end
        end
        transaction.commit();


        transaction=M3I.Transaction(oldM3IModel);
        for irvIndex=1:newM3IComp.Behavior.IRV.size()
            newIRV=newM3IComp.Behavior.IRV.at(irvIndex);
            oldIRV=matcher.get(newIRV);
            if oldIRV.isvalid()
                oldIRV.Name=newIRV.Name;
            end
        end
        transaction.commit();
    end


    deletedElements=matcher.getUnmatched();
    for deletedIdx=1:deletedElements.size()
        element=deletedElements.at(deletedIdx);
        if element.isvalid()&&autosar.ui.utils.isaValidUIObject(element)


            transaction=M3I.Transaction(oldM3IModel);
            element.destroy();
            transaction.commit();
        end
    end




