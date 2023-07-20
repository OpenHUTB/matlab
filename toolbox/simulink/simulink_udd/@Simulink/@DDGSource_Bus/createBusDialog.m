function dlgStruct=createBusDialog(source,block)









    source.getHierarchyInfo(block);


    descGroup=source.createBlkDescGroup(block);




    if isempty(source.signalSelector)
        source.createSignalSelector([]);
    end

    inputGroup=source.createInputGroup;


    outputGroup=source.createOutputGroup(block);


    invisibleGroup=source.createInvisibleGroup;

    paramGroup=source.combineGroups(block,inputGroup,outputGroup,invisibleGroup);




    dlgStruct=source.createDialogStruct(block,descGroup,paramGroup);
    dlgStruct.OpenCallback=@initialize;
end


function initialize(dlg)





    block=dlg.getSource.getBlock;
    if isfield(block.UserData,'signalHierarchy')&&...
        isempty(block.UserData.signalHierarchy)
        block.UserData.signalHierarchy=block.SignalHierarchy;
    end
end
