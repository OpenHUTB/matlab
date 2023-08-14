function block=getSingleSelectedBlock(cbinfo)




    selection=cbinfo.selection;
    block={};
    if selection.size==1&&SLStudio.Utils.objectIsValidBlock(selection.at(1))
        block=selection.at(1);
    end
end
