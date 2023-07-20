
function[path,name]=getSelectedSystem(cbinfo)

    clonedetection_selector_action_name='selectSystemCloneDetectionAction';

    pinnedSystem=cbinfo.studio.App.getPinnedSystem(clonedetection_selector_action_name);

    if~isempty(pinnedSystem)

        selectedSystem=pinnedSystem;
    else
        selection=cbinfo.getSelection;
        if size(selection)==1

            selectedSystem=selection;
        else

            selectedSystem=cbinfo.uiObject;
        end
    end

    name=selectedSystem.name;
    path=selectedSystem.getFullName;

end