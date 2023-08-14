function selectedSystem=getSelectedSystem(cbinfo)


    pinnedSystem=cbinfo.studio.App.getPinnedSystem('selectSystemEmbeddedCoderAction');
    selection=cbinfo.getSelection();

    if~isempty(pinnedSystem)
        selectedSystem=pinnedSystem;
    else
        if size(selection)==1
            if(~isprop(selection,'name')||isempty(selection.name))...
                &&(~isprop(selection,'Name')||isempty(selection.Name))
                selectedSystem=cbinfo.uiObject;
            else
                selectedSystem=selection;
            end
        else
            selectedSystem=cbinfo.uiObject;
        end
    end

end