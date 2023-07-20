function updateMappingForSharedElements(sharedElementsMatcher,...
    newSharedM3IModel,oldSharedM3IModel)









    m3iSRInterfaceSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectByMetaClass(newSharedM3IModel,...
    Simulink.metamodel.arplatform.interface.SenderReceiverInterface.MetaClass,...
    true);

    transaction=M3I.Transaction(oldSharedM3IModel);
    i_traverseSRInterfaces(sharedElementsMatcher,m3iSRInterfaceSeq);
    transaction.commit();

    m3iNVInterfaceSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectByMetaClass(newSharedM3IModel,...
    Simulink.metamodel.arplatform.interface.NvDataInterface.MetaClass,...
    true);

    transaction=M3I.Transaction(oldSharedM3IModel);
    i_traverseSRInterfaces(sharedElementsMatcher,m3iNVInterfaceSeq);
    transaction.commit();

    m3iCSInterfaceSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectByMetaClass(newSharedM3IModel,...
    Simulink.metamodel.arplatform.interface.ClientServerInterface.MetaClass,...
    true);

    transaction=M3I.Transaction(oldSharedM3IModel);
    i_traverseCSInterfaces(sharedElementsMatcher,m3iCSInterfaceSeq);
    transaction.commit();

    m3iMSInterfaceSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectByMetaClass(newSharedM3IModel,...
    Simulink.metamodel.arplatform.interface.ModeSwitchInterface.MetaClass,...
    true);

    transaction=M3I.Transaction(oldSharedM3IModel);
    for iIndex=1:m3iMSInterfaceSeq.size()
        newInterface=m3iMSInterfaceSeq.at(iIndex);
        oldInterface=sharedElementsMatcher.get(newInterface);
        if oldInterface.isvalid()
            oldInterface.Name=newInterface.Name;

            newMG=newInterface.ModeGroup;
            oldMG=sharedElementsMatcher.get(newMG);
            if oldMG.isvalid()
                oldMG.Name=newMG.Name;
            end
        end
    end
    transaction.commit();


    deletedElements=sharedElementsMatcher.getUnmatched();
    for deletedIdx=1:deletedElements.size()
        element=deletedElements.at(deletedIdx);
        if element.isvalid()&&autosar.ui.utils.isaValidUIObject(element)


            transaction=M3I.Transaction(oldSharedM3IModel);
            element.destroy();
            transaction.commit();
        end
    end


    function i_traverseSRInterfaces(matcher,m3iInterfaceSeq)

        for iIndex=1:m3iInterfaceSeq.size()
            newInterface=m3iInterfaceSeq.at(iIndex);
            oldInterface=matcher.get(newInterface);
            if oldInterface.isvalid()
                oldInterface.Name=newInterface.Name;
            end

            for dIndex=1:newInterface.DataElements.size()
                newDE=newInterface.DataElements.at(dIndex);
                oldDE=matcher.get(newDE);
                if oldDE.isvalid()
                    oldDE.Name=newDE.Name;
                end
            end
        end

        function i_traverseCSInterfaces(matcher,m3iInterfaceSeq)

            for intIdx=1:m3iInterfaceSeq.size()
                newInterface=m3iInterfaceSeq.at(intIdx);
                oldInterface=matcher.get(newInterface);
                if oldInterface.isvalid()
                    oldInterface.Name=newInterface.Name;
                end

                for opIdx=1:newInterface.Operations.size()
                    newOp=newInterface.Operations.at(opIdx);
                    oldOp=matcher.get(newOp);
                    if oldOp.isvalid()
                        oldOp=matcher.get(newOp);
                        oldOp.Name=newOp.Name;

                        for argIdx=1:newOp.Arguments.size()
                            newArg=newOp.Arguments.at(argIdx);
                            oldArg=matcher.get(newArg);
                            if oldArg.isvalid()
                                oldArg.Name=newArg.Name;
                            end
                        end
                    end
                end
            end




