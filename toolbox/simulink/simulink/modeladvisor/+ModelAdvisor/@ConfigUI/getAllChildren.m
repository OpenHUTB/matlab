function childrenObj=getAllChildren(this)






    if strcmp(this.Type,'Task')
        childrenObj={this};
    else
        childrenObj={};
        for i=1:length(this.ChildrenObj)
            childrenObj=[childrenObj,getAllChildren(this.ChildrenObj{i})];%#ok<AGROW>
        end
    end

