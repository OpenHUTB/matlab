function[model,idStack]=getSfLibInstanceParentModel(needIds)





    model=[];
    idStack=[];

    if nargin==0
        needIds=false;
    elseif(nargout<2)
        needIds=false;
    end

    editor=StateflowDI.SFDomain.getLastActiveEditor();
    if isempty(editor)
        return;
    end

    hid=editor.getHierarchyId;
    pid=GLUE2.HierarchyService.getParent(hid);

    fullname='';
    while GLUE2.HierarchyService.isValid(pid)
        m3iobj=GLUE2.HierarchyService.getM3IObject(pid);
        obj=m3iobj.temporaryObject;

        if(strfind(class(obj),'StateflowDI.')==1)
            fullname=obj.getFullName;
            if needIds
                idStack(end+1)=double(obj.backendId);%#ok<AGROW>
            end
        else


            fullname=obj.getFullPathName;
            break;
        end
        pid=GLUE2.HierarchyService.getParent(pid);
    end

    if~isempty(fullname)
        model=get_param(bdroot(fullname),'handle');
    else
        model=editor.blockDiagramHandle;
    end
end
