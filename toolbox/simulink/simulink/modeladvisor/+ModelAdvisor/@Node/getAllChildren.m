function childrenObj=getAllChildren(this)






    if isa(this,'ModelAdvisor.Task')
        childrenObj={this};
    else
        childrenObj={};
        for i=1:length(this.ChildrenObj)
            childrenObj=[childrenObj,getAllChildren(this.ChildrenObj{i})];%#ok<AGROW>
        end
    end

