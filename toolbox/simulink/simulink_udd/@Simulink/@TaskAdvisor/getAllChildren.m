function childrenObj=getAllChildren(this)




    if isempty(this.ChildrenObj)
        childrenObj={this};
    else
        childrenObj={};
        for i=1:length(this.ChildrenObj)
            childrenObj=[childrenObj,getAllChildren(this.ChildrenObj{i})];%#ok<AGROW>
        end
    end

