



function[obj,name,path,selected,state,message]=getSystemSelectorInfo(userdata,cbinfo,action)
    pinnedSystem=cbinfo.studio.App.getPinnedSystem(action.name);

    if(~isempty(pinnedSystem))
        is_handle=strcmp(class(pinnedSystem),'handle');

        no_path_found=~isprop(pinnedSystem,'Path')||isempty(pinnedSystem.Path);

        if(is_handle||no_path_found)
            cbinfo.studio.App.erasePinnedSystem(action.name);
            pinnedSystem=cbinfo.studio.App.getPinnedSystem(action.name);
        end
    end

    if isempty(pinnedSystem)
        selected=false;
        obj=SLStudio.toolstrip.internal.getSystemSelectorSelection(cbinfo);
    else
        selected=true;
        obj=pinnedSystem;
    end

    name=obj.name;
    path=obj.getFullName;

    [state,message]=feval(userdata,obj,cbinfo);
end