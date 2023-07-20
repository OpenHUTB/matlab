function tf=acceptDrop(this,acceptNode,dropObjects)







    ModelAdvisor.ConfigUI.stackoperation('push');
    for i=1:length(dropObjects)
        tf=dropSingleObj(acceptNode,dropObjects{i});
        if~tf
            return
        end
    end
    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('HierarchyChangedEvent',acceptNode);

    function tf=dropSingleObj(this,dropObjects)
        if isempty(dropObjects)||isequal(this,dropObjects)
            tf=false;
            return;
        end








        if~dropObjects.InLibrary
            dropObjects.detach;
        end


        newParent={};
        position=0;
        if strcmp(this.Type,'Task')
            if isa(this.ParentObj,'ModelAdvisor.ConfigUI')&&strcmp(this.ParentObj.Type,'Group')
                newParent=this.ParentObj;
                for i=1:length(newParent.ChildrenObj)
                    if strcmp(newParent.ChildrenObj{i}.ID,this.ID)
                        position=i+1;
                    end
                end
            end
        else
            newParent=this;
            position=length(newParent.ChildrenObj)+1;
        end


        if dropObjects.InLibrary
            copyFromLibObjects=copytree(dropObjects);
            this.MAObj.ConfigUICellArray=[this.MAObj.ConfigUICellArray,copyFromLibObjects];
            dropObjects=copyFromLibObjects{1};
        end



        dropObjects.attach(newParent,position);

        if position==0
            tf=false;
            return;
        end

        tf=true;
