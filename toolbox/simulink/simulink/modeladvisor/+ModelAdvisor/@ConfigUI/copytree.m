function copyobj=copytree(this)




    if isa(this.MAObj,'Simulink.ModelAdvisor')
        origDirty=this.MAObj.ConfigUIDirty;
    end

    copyobj=recursivecopy(this,{});

    if isa(this.MAObj,'Simulink.ModelAdvisor')
        this.MAObj.ConfigUIDirty=origDirty;
    end

    function nodecell=recursivecopy(this,parentObj)
        nodecell={};

        if isa(this,'ModelAdvisor.ConfigUI')
            nodecell{end+1}=copy(this);
            nodecell{end}.ParentObj=parentObj;
            if isa(parentObj,'ModelAdvisor.ConfigUI')

                parentObj.addChildren(nodecell{end});
            end
            nodecell{end}.ChildrenObj={};
            nodecell{end}.InLibrary=false;
            if isa(parentObj,'ModelAdvisor.ConfigUI')
                parentObj.ChildrenObj{end+1}=nodecell{end};
            end
            nextparent=nodecell{end};
            for i=1:length(this.ChildrenObj)
                nodecell=[nodecell,recursivecopy(this.ChildrenObj{i},nextparent)];%#ok<AGROW>
            end
        end
