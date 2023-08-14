function obj=getSingleSelection(cbinfo)




    obj=[];
    if cbinfo.selection.size==1
        obj=cbinfo.selection.at(1);
    end
end
