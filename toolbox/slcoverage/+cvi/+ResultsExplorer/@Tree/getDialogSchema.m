
function dlgStruct=getDialogSchema(obj,s)




    try
        if obj==obj.resultsExplorer.root.passiveTree
            dlgStruct=getPassiveDialogSchema(obj,s);
        else
            dlgStruct=getActiveDialogSchema(obj,s);
        end
    catch MEx
        display(MEx.stack(1));
    end
end
