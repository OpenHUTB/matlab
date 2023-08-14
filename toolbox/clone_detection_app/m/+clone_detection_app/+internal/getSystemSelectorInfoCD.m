

function[obj,name,path,selected,state,message]=getSystemSelectorInfoCD(userdata,cbinfo,action)
    selection=cbinfo.getSelection();
    pinnedSystem=cbinfo.studio.App.getPinnedSystem(action.name);

    if isempty(pinnedSystem)
        selected=false;

        if size(selection)==1
            if(~isprop(selection,'name')||isempty(selection.name))...
                &&(~isprop(selection,'Name')||isempty(selection.Name))
                obj=cbinfo.uiObject;
            else
                obj=selection;
            end
        else
            obj=cbinfo.uiObject;
        end
    else
        selected=true;
        obj=pinnedSystem;
    end

    if obj.isModelReference
        name=obj.ModelName;
        path=obj.ModelName;
    else
        name=obj.name;
        path=obj.getFullName;
    end

    [state,message]=feval(userdata,obj);
end
