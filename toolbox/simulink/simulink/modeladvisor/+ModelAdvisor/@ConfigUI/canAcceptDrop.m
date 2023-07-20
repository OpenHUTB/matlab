function dropok=canAcceptDrop(~,acceptNode,dropObjects)




    dropok=false;


    if acceptNode.InLibrary
        dropok=false;
        return;
    end


    if acceptNode.MAObj.EdittimeViewMode
        dropok=false;
        return;
    end

    for i=1:length(dropObjects)

        if isempty(dropObjects{i}.ParentObj)
            dropok=false;
            return;
        end

        if dropObjects{1}.InLibrary&&strcmp(dropObjects{1}.DisplayName,DAStudio.message('Simulink:tools:MACBTitle'))
            dropok=false;
            return;
        end

        if isa(dropObjects{i},'ModelAdvisor.ConfigUI')


            dropok=~isParent(dropObjects{i},acceptNode)&&~isGrandParent(acceptNode,dropObjects{i});

            if strcmp(dropObjects{i}.Type,'Task')&&isempty(acceptNode.ParentObj)
                dropok=false;
            end
        else
            dropok=false;
        end
        if~dropok
            return;
        end
        if strcmp(acceptNode.Type,'Task')&&isa(acceptNode.ParentObj,'ModelAdvisor.ConfigUI')
            dropToFolder=acceptNode.ParentObj;
        else
            dropToFolder=acceptNode;
        end
        if isa(dropObjects{i}.ParentObj,'ModelAdvisor.ConfigUI')&&strcmp(dropObjects{i}.ParentObj.ID,dropToFolder.ID)&&~dropObjects{i}.InLibrary
            noNeedCheckDupName=true;
        else
            noNeedCheckDupName=false;
        end
        if~noNeedCheckDupName
            for j=1:length(dropToFolder.ChildrenObj)

                if strcmp(dropToFolder.ChildrenObj{j}.DisplayName,dropObjects{i}.DisplayName)
                    dropok=false;
                    return;
                end
            end
        end
    end


    function tf=isParent(childObj,parentObj)

        childParent=childObj.ParentObj;
        if isempty(childParent)
            tf=false;
        else


            if strcmp(childParent.ID,parentObj.ID)&&~childParent.InLibrary
                tf=true;
            else
                tf=false;
            end
        end

        function tf=isGrandParent(childObj,parentObj)

            if isParent(childObj,parentObj)
                tf=true;
            elseif~isempty(childObj.ParentObj)
                tf=isGrandParent(childObj.ParentObj,parentObj);
            else
                tf=false;
            end
