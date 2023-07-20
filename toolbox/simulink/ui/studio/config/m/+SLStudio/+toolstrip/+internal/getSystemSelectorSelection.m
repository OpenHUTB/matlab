



function[obj]=getSystemSelectorSelection(cbinfo)
    selection=cbinfo.getSelection;

    if size(selection)==1
        if(~isprop(selection,'name')||isempty(selection.name))...
            &&(~isprop(selection,'Name')||isempty(selection.Name))
            obj=SLStudio.toolstrip.internal.getHierarchicalBlock(cbinfo);
        else
            obj=selection;
        end
    else
        obj=SLStudio.toolstrip.internal.getHierarchicalBlock(cbinfo);
    end
end